#!/usr/bin/env bash
#
# Orbit server — turnkey installer.
#
# Served at https://cosmique.io/orbit/install.sh — install with:
#
#   curl -fsSL https://cosmique.io/orbit/install.sh | bash
#
# Generates a docker compose stack in $ORBIT_INSTALL_DIR (default
# /opt/orbit), pulls the published image from GHCR, and starts it. The
# repo is never needed — the image is self-contained.
#
# Configure interactively (a TTY is detected even when piped from curl)
# or non-interactively by presetting env vars:
#
#   ORBIT_DOMAIN=orbit.example.com \
#   ORBIT_MUSIC_DIR=/srv/music \
#   ORBIT_IMAGE_TAG=edge \
#   bash <(curl -fsSL https://cosmique.io/orbit/install.sh)
#
# Leave ORBIT_DOMAIN empty for a no-TLS test deploy (plain HTTP on :9899).

set -euo pipefail

# ── settings (env-overridable) ───────────────────────────────────────
INSTALL_DIR="${ORBIT_INSTALL_DIR:-/opt/orbit}"
IMAGE_TAG="${ORBIT_IMAGE_TAG:-edge}"
IMAGE="ghcr.io/cosmique-source/orbit:${IMAGE_TAG}"
TZ_VAL="${ORBIT_TZ:-UTC}"
# Runtime uid/gid. The container's entrypoint drops to these and owns its
# state accordingly; the installer also chowns the host dirs to match, so
# there's no manual chown. Default 1000 (the image's baked-in user).
PUID="${ORBIT_PUID:-1000}"
PGID="${ORBIT_PGID:-1000}"

# ── ui helpers ───────────────────────────────────────────────────────
c_blue=$'\033[34m'; c_green=$'\033[32m'; c_red=$'\033[31m'; c_dim=$'\033[2m'; c_off=$'\033[0m'
log()  { printf '%s==>%s %s\n' "$c_blue"  "$c_off" "$*"; }
ok()   { printf '%s ok%s %s\n' "$c_green" "$c_off" "$*"; }
warn() { printf '%swarn%s %s\n' "$c_red"  "$c_off" "$*" >&2; }
die()  { printf '%serror%s %s\n' "$c_red" "$c_off" "$*" >&2; exit 1; }

# prompt VAR "text" "default" — no-op if VAR is already defined in the
# environment (even if set to empty, so `ORBIT_DOMAIN=` means "no domain,
# don't ask"). Falls back to the default when there's no TTY to read from.
prompt() {
	local -n _ref="$1"
	local text="$2" def="${3:-}" val=""
	[ -n "${_ref+x}" ] && return
	if [ -r /dev/tty ]; then
		printf '%s%s%s ' "$c_blue" "$text" "$c_off" > /dev/tty
		[ -n "$def" ] && printf '%s[%s]%s ' "$c_dim" "$def" "$c_off" > /dev/tty
		read -r val < /dev/tty 2>/dev/null || true
	fi
	_ref="${val:-$def}"
}

# Run a command as root, via sudo only if we aren't already root.
as_root() {
	if [ "$(id -u)" -eq 0 ]; then "$@"; else sudo "$@"; fi
}

# ── preflight ────────────────────────────────────────────────────────
log "Orbit installer"

if ! command -v docker >/dev/null 2>&1; then
	warn "Docker is not installed."
	prompt INSTALL_DOCKER "Install Docker now via get.docker.com? (y/N)" "n"
	case "${INSTALL_DOCKER,,}" in
		y|yes) log "Installing Docker…"; curl -fsSL https://get.docker.com | as_root sh ;;
		*) die "Docker is required. Install it and re-run." ;;
	esac
fi
docker compose version >/dev/null 2>&1 || die "The Docker Compose plugin is required (docker compose v2)."
command -v openssl >/dev/null 2>&1 || die "openssl is required (to generate the auth secret)."
ok "Docker $(docker --version | awk '{print $3}' | tr -d ,) present"

# ── gather config ────────────────────────────────────────────────────
prompt ORBIT_DOMAIN   "Domain for TLS (blank = plain HTTP test deploy):" ""
prompt ORBIT_MUSIC_DIR "Host path to your music library:" "${INSTALL_DIR}/music"

MUSIC_DIR="$ORBIT_MUSIC_DIR"
# Read-only import source: drop new albums here, then import them from the
# UI's directory browser (wired into ingestion.watch_directories below).
IMPORT_DIR="${ORBIT_IMPORT_DIR:-${INSTALL_DIR}/import}"
SECRET="$(openssl rand -hex 32)"

if [ -n "$ORBIT_DOMAIN" ]; then
	MODE="TLS (Caddy) for ${ORBIT_DOMAIN}"
else
	MODE="plain HTTP on :9899 (no TLS)"
fi
log "Installing to ${INSTALL_DIR} — ${MODE}, image ${IMAGE}"

# ── lay down files ───────────────────────────────────────────────────
as_root mkdir -p "$INSTALL_DIR" "$MUSIC_DIR" "$IMPORT_DIR"
# The container runs as uid 1000; it organizes files into /music and writes
# tag temp files in /import, so it must own both. Non-recursive so we don't
# rewrite ownership of an existing library you point MUSIC_DIR at — that
# case needs `chown -R $PUID:$PGID` yourself for managed organization.
as_root chown "$PUID:$PGID" "$MUSIC_DIR" "$IMPORT_DIR"

# config (auth on, secret baked in)
as_root tee "$INSTALL_DIR/orbit-config.yaml" >/dev/null <<EOF
server:
  port: 9899
  host: 0.0.0.0
database:
  sqlite_path: /data/orbit.db
ingestion:
  music_root: /music
  # Read-only import sources the UI directory browser can reach. The
  # browser is jailed to music_root + these paths, so /import must be
  # listed here for dropped-in albums to appear in the import flow.
  watch_directories:
    - /import
  # Matcher engine. The redesigned import UI (matchFolder) needs the
  # deterministic engine; "musicbrainz_api" (the default) does NOT support
  # it and returns "deterministic engine is not configured". deterministic_api
  # talks to the public MB /ws/2 API (no Postgres replica needed) and works
  # anonymously (rate 1/s) until you set MB credentials in Settings.
  matcher:
    engine: deterministic_api
  musicbrainz:
    enabled: true
    api_url: https://musicbrainz.org/ws/2/
    rate_limit_ms: 1100
    user_agent: "Orbit/1.0.0 (https://orbit.audio)"
  classical:
    use_open_opus: true
    open_opus_api_url: https://api.openopus.org
scanner:
  enabled: false
auth:
  jwt_secret: "${SECRET}"
  access_token_expiry: "15m"
  refresh_token_expiry: "7d"
EOF
# The container runs as the non-root "orbit" user (uid 1000); it must be
# able to read the mounted config (it's :ro, so the entrypoint can't chown
# it — the host must). Own it by PUID and keep it private (0600) so the
# jwt_secret isn't world-readable on the host.
as_root chown "$PUID:$PGID" "$INSTALL_DIR/orbit-config.yaml"
as_root chmod 600 "$INSTALL_DIR/orbit-config.yaml"

# compose — caddy block only when a domain is set
if [ -n "$ORBIT_DOMAIN" ]; then
	as_root tee "$INSTALL_DIR/Caddyfile" >/dev/null <<EOF
${ORBIT_DOMAIN} {
	encode zstd gzip
	reverse_proxy orbit:9899 {
		header_up X-Real-IP {remote_host}
		header_up X-Forwarded-Proto {scheme}
		transport http {
			read_timeout 0s
			write_timeout 0s
			dial_timeout 10s
		}
	}
}
EOF
	as_root tee "$INSTALL_DIR/docker-compose.yml" >/dev/null <<EOF
services:
  orbit:
    image: ${IMAGE}
    container_name: orbit
    restart: unless-stopped
    expose: ["9899"]
    environment: [TZ=${TZ_VAL}, PUID=${PUID}, PGID=${PGID}]
    volumes:
      - ${MUSIC_DIR}:/music
      - ${IMPORT_DIR}:/import
      - orbit_data:/data
      - ./orbit-config.yaml:/app/orbit-config.yaml:ro
  caddy:
    image: caddy:2-alpine
    container_name: orbit-caddy
    restart: unless-stopped
    depends_on: [orbit]
    ports: ["80:80", "443:443"]
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
volumes:
  orbit_data:
  caddy_data:
  caddy_config:
EOF
else
	as_root tee "$INSTALL_DIR/docker-compose.yml" >/dev/null <<EOF
services:
  orbit:
    image: ${IMAGE}
    container_name: orbit
    restart: unless-stopped
    ports: ["9899:9899"]
    environment: [TZ=${TZ_VAL}, PUID=${PUID}, PGID=${PGID}]
    volumes:
      - ${MUSIC_DIR}:/music
      - ${IMPORT_DIR}:/import
      - orbit_data:/data
      - ./orbit-config.yaml:/app/orbit-config.yaml:ro
volumes:
  orbit_data:
EOF
fi
ok "Wrote compose + config to ${INSTALL_DIR}"

# ── pull & launch ────────────────────────────────────────────────────
log "Pulling ${IMAGE}…"
if ! as_root docker compose -f "$INSTALL_DIR/docker-compose.yml" pull 2>/tmp/orbit-pull.err; then
	if grep -qiE 'denied|unauthorized|401' /tmp/orbit-pull.err; then
		warn "Pull was denied — the image is private. Log in first:"
		warn "  echo \$GHCR_PAT | docker login ghcr.io -u <github-user> --password-stdin"
	fi
	cat /tmp/orbit-pull.err >&2
	die "Image pull failed."
fi

log "Starting…"
as_root docker compose -f "$INSTALL_DIR/docker-compose.yml" up -d

# ── done ─────────────────────────────────────────────────────────────
echo
if [ -n "$ORBIT_DOMAIN" ]; then
	ok "Orbit is up at https://${ORBIT_DOMAIN}"
	echo "${c_dim}   (Caddy issues the TLS cert on first request — give it ~30s.${c_off}"
	echo "${c_dim}    The A record for ${ORBIT_DOMAIN} must point at this box.)${c_off}"
else
	ip="$(curl -fsS https://api.ipify.org 2>/dev/null || echo '<this-box-ip>')"
	ok "Orbit is up at http://${ip}:9899"
fi
echo "${c_dim}   Music library: ${MUSIC_DIR} → /music   (managed-library destination, writable)${c_off}"
echo "${c_dim}   Import drop:   ${IMPORT_DIR} → /import (drop new albums here, import from the UI)${c_off}"
echo "${c_dim}   Logs:    docker compose -f ${INSTALL_DIR}/docker-compose.yml logs -f orbit${c_off}"
echo "${c_dim}   Update:  docker compose -f ${INSTALL_DIR}/docker-compose.yml pull && … up -d${c_off}"
