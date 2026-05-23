// Cosmique — sample screens. These mirror the HTML preview wall, built with
// real SwiftUI + the tokens/components. They drive both the Xcode #Preview
// canvas and the snapshot export (SnapshotTests).
import SwiftUI

// Shared vinyl-record artwork (dark, regardless of theme — like real album art).
struct VinylArt: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Cosmique.Radius.md).fill(Color(rgb: 0x15110E))
            Circle().strokeBorder(Color(rgb: 0xE9E3D4).opacity(0.14), lineWidth: 1).padding(22)
            Circle().strokeBorder(Color(rgb: 0xE9E3D4).opacity(0.14), lineWidth: 1).padding(44)
            Circle().strokeBorder(Color(rgb: 0xE9E3D4).opacity(0.14), lineWidth: 1).padding(66)
            Circle().fill(Cosmique.Color.accent).frame(width: 58, height: 58)
            Circle().fill(Color(rgb: 0x15110E)).frame(width: 12, height: 12)
        }
    }
}

private func hairlineBottom() -> some View { Rectangle().fill(Cosmique.Color.hair).frame(height: 1) }

// MARK: - Orbit — Now Playing

public struct OrbitNowPlayingSample: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VinylArt().aspectRatio(1, contentMode: .fit).padding(.bottom, Cosmique.Space.md)
            Text("The Dark Side of the Moon").cosmique(.h3).foregroundStyle(Cosmique.Color.ink)
            Text("Pink Floyd").cosmique(.small).foregroundStyle(Cosmique.Color.muted).padding(.top, 2)
            Pill("1973 UK · original pressing", accent: true).padding(.top, Cosmique.Space.sm)
            ZStack(alignment: .leading) {
                Capsule().fill(Cosmique.Color.hair).frame(height: 3)
                Capsule().fill(Cosmique.Color.accent).frame(width: 130, height: 3)
            }.padding(.top, Cosmique.Space.md)
            HStack {
                Text("14:02").cosmique(.small).foregroundStyle(Cosmique.Color.muted)
                Spacer()
                Text("−9:11").cosmique(.small).foregroundStyle(Cosmique.Color.muted)
            }.padding(.top, 6)
            HStack(spacing: 30) {
                Spacer()
                Image(systemName: "backward.fill")
                Image(systemName: "play.fill")
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Cosmique.Color.accent)
                    .clipShape(Circle())
                Image(systemName: "forward.fill")
                Spacer()
            }.foregroundStyle(Cosmique.Color.ink).padding(.top, Cosmique.Space.md)
            Spacer()
        }
        .padding(Cosmique.Space.md)
        .cosmiqueScreen()
    }
}

// MARK: - Orbit — Album detail (pressings)

public struct OrbitAlbumSample: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VinylArt().aspectRatio(1, contentMode: .fit).padding(.bottom, Cosmique.Space.sm)
            Text("Kind of Blue").cosmique(.h3).foregroundStyle(Cosmique.Color.ink)
            Text("Miles Davis · 1959").cosmique(.small).foregroundStyle(Cosmique.Color.muted)
            sectionLabel("Pressings · 3")
            pressing("1959 Columbia, original mono", "DSD64", fav: true)
            pressing("1997 Legacy remaster", "FLAC 16/44", fav: false)
            pressing("2013 Analogue Productions", "24/192", fav: false)
            sectionLabel("Tracks")
            track("1 · So What", "9:22")
            track("2 · Freddie Freeloader", "9:46")
            track("3 · Blue in Green", "5:37")
            Spacer()
        }
        .padding(Cosmique.Space.md)
        .cosmiqueScreen()
    }
    private func sectionLabel(_ t: String) -> some View {
        Text(t).cosmique(.mono).foregroundStyle(Cosmique.Color.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Cosmique.Space.md).padding(.bottom, 6)
            .overlay(alignment: .bottom) { Rectangle().fill(Cosmique.Color.ink).frame(height: 1) }
    }
    private func pressing(_ name: String, _ fmt: String, fav: Bool) -> some View {
        HStack {
            Text(name).cosmique(.small).foregroundStyle(fav ? Cosmique.Color.accent : Cosmique.Color.ink)
            Spacer()
            Text(fav ? "\(fmt) ★" : fmt).cosmique(.mono).foregroundStyle(Cosmique.Color.muted)
        }
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) { hairlineBottom() }
    }
    private func track(_ name: String, _ dur: String) -> some View {
        HStack {
            Text(name).cosmique(.small).foregroundStyle(Cosmique.Color.ink)
            Spacer()
            Text(dur).cosmique(.mono).foregroundStyle(Cosmique.Color.muted)
        }
        .padding(.vertical, 7)
        .overlay(alignment: .bottom) { hairlineBottom() }
    }
}

// MARK: - Bulletin — Reading view

public struct BulletinReaderSample: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("‹ Unread").cosmique(.small).foregroundStyle(Cosmique.Color.muted)
            Text("The quiet return of the RSS reader")
                .font(.system(size: 23, weight: .bold, design: .serif))
                .foregroundStyle(Cosmique.Color.ink).padding(.top, 10)
            Text("PIXEL ENVY · 6 MIN READ")
                .font(.system(size: 10)).tracking(1.2)
                .foregroundStyle(Cosmique.Color.muted).padding(.top, 10)
            RoundedRectangle(cornerRadius: Cosmique.Radius.md)
                .fill(LinearGradient(colors: [Color(rgb: 0x8A8C6F), Color(rgb: 0x3B4A3A)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 110).padding(.vertical, 14)
            Text("For a decade the feed reader was declared dead, killed off the day Google Reader closed. The people who kept reading this way never quite believed it.")
                .font(.system(size: 14, design: .serif)).lineSpacing(4)
                .foregroundStyle(Cosmique.Color.ink)
            Text("The web didn't get quieter. We just stopped choosing what reached us.")
                .font(.system(size: 15, design: .serif)).italic()
                .foregroundStyle(Cosmique.Color.ink)
                .padding(.leading, 12).padding(.vertical, 11)
                .overlay(alignment: .leading) { Rectangle().fill(Cosmique.Color.accent).frame(width: 2) }
            Spacer()
        }
        .padding(.horizontal, 20).padding(.top, Cosmique.Space.sm)
        .cosmiqueScreen()
    }
}

// MARK: - Bilan — Month summary

public struct BilanSummarySample: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("JANUARY 2025 · CASHFLOW").cosmique(.mono).foregroundStyle(Cosmique.Color.muted)
            Text("−$3,982").font(.system(size: 40, weight: .bold)).monospacedDigit()
                .foregroundStyle(Cosmique.Color.negative).padding(.top, 2)
            HStack(spacing: 10) {
                stat("INCOME", "$14,817", Cosmique.Color.positive)
                stat("EXPENSES", "$18,799", Cosmique.Color.negative)
            }.padding(.vertical, 16)
            Text("RECENT").cosmique(.mono).foregroundStyle(Cosmique.Color.muted)
                .frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 4)
                .overlay(alignment: .bottom) { Rectangle().fill(Cosmique.Color.ink).frame(height: 1) }
            row("Woolworths", "09 Jan · groceries", "−$148.27", Cosmique.Color.negative)
            row("Spotify", "09 Jan · subscriptions", "−$27.99", Cosmique.Color.negative)
            row("Smartsalary", "08 Jan · salary", "+$1,223.07", Cosmique.Color.positive)
            Spacer()
        }
        .padding(Cosmique.Space.md)
        .cosmiqueScreen()
    }
    private func stat(_ l: String, _ v: String, _ c: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(l).cosmique(.mono).foregroundStyle(Cosmique.Color.muted)
            Text(v).font(.system(size: 17, weight: .bold)).monospacedDigit().foregroundStyle(c)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cosmiqueCard(padding: 11)
    }
    private func row(_ name: String, _ meta: String, _ amt: String, _ c: Color) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(name).cosmique(.small).foregroundStyle(Cosmique.Color.ink)
                Text(meta).cosmique(.mono).foregroundStyle(Cosmique.Color.muted)
            }
            Spacer()
            Text(amt).cosmique(.mono).foregroundStyle(c)
        }
        .padding(.vertical, 9)
        .overlay(alignment: .bottom) { hairlineBottom() }
    }
}

// MARK: - Frequence — Library + mini-player

public struct FrequenceLibrarySample: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            KickerLabel("Frequence").padding(.bottom, 4)
            Text("Library").cosmique(.h2).foregroundStyle(Cosmique.Color.ink)
            HStack(spacing: 6) {
                Pill("All", accent: true); Pill("Podcasts"); Pill("Articles")
            }.padding(.vertical, 10)
            ep("The Future of Self-Hosting", "Late Night Linux · 48 min", 0x3B4A3A, now: true)
            ep("On designing for permanence", "Article · spoken · 12 min", 0x4A6275, now: false)
            ep("Webb's latest deep-field images", "The Verge · 33 min", 0x8A4B3A, now: false)
            Spacer()
            HStack(spacing: 11) {
                RoundedRectangle(cornerRadius: 6).fill(Color(rgb: 0x3B4A3A)).frame(width: 34, height: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text("The Future of Self-Hosting").cosmique(.small).foregroundStyle(Cosmique.Color.ink).lineLimit(1)
                    Text("Late Night Linux").font(.system(size: 10)).foregroundStyle(Cosmique.Color.muted)
                }
                Spacer()
                Image(systemName: "pause.fill"); Image(systemName: "forward.fill")
            }
            .foregroundStyle(Cosmique.Color.ink)
            .padding(.horizontal, 13).padding(.vertical, 10)
            .background(Cosmique.Color.card)
            .overlay(alignment: .top) { hairlineBottom() }
        }
        .padding(.horizontal, 16).padding(.top, Cosmique.Space.sm)
        .cosmiqueScreen()
    }
    private func ep(_ t: String, _ m: String, _ color: UInt, now: Bool) -> some View {
        HStack(spacing: 11) {
            RoundedRectangle(cornerRadius: 8).fill(Color(rgb: color)).frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 3) {
                Text(t).cosmique(.small).foregroundStyle(now ? Cosmique.Color.accent : Cosmique.Color.ink)
                Text(m).font(.system(size: 10.5)).foregroundStyle(Cosmique.Color.muted)
            }
            Spacer()
        }
        .padding(.vertical, 11)
        .overlay(alignment: .top) { hairlineBottom() }
    }
}

// MARK: - Registry (used by the snapshot exporter)

public enum CosmiqueSamples {
    public static let all: [(name: String, view: AnyView)] = [
        ("orbit-nowplaying", AnyView(OrbitNowPlayingSample())),
        ("orbit-album",       AnyView(OrbitAlbumSample())),
        ("bulletin-reader",   AnyView(BulletinReaderSample())),
        ("bilan-summary",     AnyView(BilanSummarySample())),
        ("frequence-library", AnyView(FrequenceLibrarySample()))
    ]
}

// MARK: - Xcode canvas previews

#if DEBUG
#Preview("Orbit — Now Playing · light") { OrbitNowPlayingSample() }
#Preview("Orbit — Now Playing · dark") { OrbitNowPlayingSample().preferredColorScheme(.dark) }
#Preview("Orbit — Album") { OrbitAlbumSample() }
#Preview("Bulletin — Reader") { BulletinReaderSample() }
#Preview("Bilan — Summary") { BilanSummarySample() }
#Preview("Frequence — Library · dark") { FrequenceLibrarySample().preferredColorScheme(.dark) }
#endif
