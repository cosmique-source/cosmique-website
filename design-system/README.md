# Cosmique Design System

The "baked out" version of the design language used across the Cosmique mockups
(homepage, Bulletin, Orbit). One source of truth, consumable from **web (CSS)** and
**iOS (SwiftUI)**.

```
design-system/
├── tokens.json          ← edit this. The single source of truth.
├── build-tokens.mjs     ← run this. Generates the CSS + Swift below.
├── css/
│   ├── tokens.css       ← GENERATED — CSS custom properties (light + dark + forced)
│   ├── base.css         ← reset, page, grain texture, type defaults
│   ├── components.css   ← reusable patterns (buttons, cards, grids, device frames, …)
│   └── cosmique.css     ← the single file you link (imports the three)
├── js/theme.js          ← shared light/dark toggle (persists + applies pre-paint)
├── styleguide.html      ← the kitchen-sink reference. Open this first.
├── snapshots.html       ← wall of real SwiftUI renders (filled by the test below)
├── snapshots/           ← GENERATED PNGs (from the snapshot test)
└── CosmiquePreviews/    ← Swift Package: tokens + SwiftUI components + sample screens
    ├── Package.swift
    └── Sources/CosmiqueUI/
        ├── Tokens.swift     ← GENERATED — SwiftUI palette + scales
        ├── Components.swift ← SwiftUI mirror of components.css (font, card, KickerLabel…)
        └── Samples.swift    ← sample screens + #Preview blocks
```

## See it
Open **`styleguide.html`** in a browser — every token and component on one page,
with a light/dark toggle (top right).

## Use it on the web
```html
<link rel="stylesheet" href="…/design-system/css/cosmique.css">
```
Then use the component classes: `.kick`, `.btn`, `.btn-secondary`, `.card`,
`.feature-grid`/`.feature`, `.pillars`, `.tiers`/`.tier`, `.spec-table`,
`.gallery`, `.callout`, `.ds-header`/`.nav`, `.ds-footer`.

**Dark mode** is one attribute — no separate stylesheet:
```html
<html data-theme="dark">     <!-- or toggle it with JS -->
```

**Per-app accent.** The whole system keys off `--color-accent` (brick by default).
Override it on a page and buttons, dots, links, prices all follow:
```css
.bulletin-page { --color-accent: #7BA05B; }  /* Bulletin green */
```

## Use it in the iOS apps
Add the `CosmiquePreviews` package via SPM (or drop the files in). It ships the
tokens **and** a thin SwiftUI component layer (`Components.swift`):
```swift
import CosmiqueUI

VStack(alignment: .leading, spacing: Cosmique.Space.md) {
    KickerLabel("Now playing")
    Text("Listen closely").cosmique(.h1).foregroundStyle(Cosmique.Color.ink)
    Pill("1973 UK · original", accent: true)
}
.cosmiqueCard()                 // hairline card, like .card in CSS
.background(Cosmique.Color.paper)   // resolves light/dark automatically
```

## Native previews (real SwiftUI, in one place)
The package has `#Preview` screens for the Xcode canvas, plus a snapshot test that
renders each one to a PNG via `ImageRenderer`:
```sh
cd design-system/CosmiquePreviews
xcodebuild test -scheme CosmiquePreviews -destination 'platform=iOS Simulator,name=iPhone 15'
```
PNGs land in `snapshots/`; open `snapshots.html` to see them all in device frames.
Doubles as visual-regression — commit the PNGs and diff after a token change.

## Change a value
1. Edit `tokens.json`.
2. `node build-tokens.mjs` → rewrites `css/tokens.css` and `CosmiquePreviews/Sources/CosmiqueUI/Tokens.swift`.
3. Refresh the browser; re-run the snapshot test for the native wall. Web + apps stay in sync.

## Going further (optional)
`tokens.json` is shaped so it maps cleanly onto **Style Dictionary** if you outgrow
the 60-line generator: each colour is a token with `light`/`dark` modes; sizes,
spacing and radius are dimensions. Add a `config.json` and `style-dictionary build`
can target CSS, SwiftUI, Android, and Figma (via Tokens Studio) from the same file.
For one person shipping a few apps, the included generator is usually enough.
```
