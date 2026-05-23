// Renders every Cosmique sample screen to a PNG (light + dark) using ImageRenderer.
// Run on an iOS Simulator for accurate dynamic colours:
//
//   xcodebuild test -scheme CosmiquePreviews \
//     -destination 'platform=iOS Simulator,name=iPhone 15'
//
// PNGs land in design-system/snapshots/, which snapshots.html displays.
import XCTest
import SwiftUI
@testable import CosmiqueUI

final class SnapshotTests: XCTestCase {

    @MainActor
    func testExportSnapshots() throws {
        #if canImport(UIKit)
        let out = Self.snapshotDir()
        try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)

        let size = CGSize(width: 393, height: 852) // iPhone 15 logical points
        for (name, view) in CosmiqueSamples.all {
            for dark in [false, true] {
                let suffix = dark ? "dark" : "light"
                let url = out.appending(path: "\(name)-\(suffix).png")
                try render(view, size: size, dark: dark, to: url)
            }
        }
        print("✓ Cosmique snapshots written to \(out.path)")
        #else
        throw XCTSkip("Snapshots need UIKit — run with an iOS Simulator destination.")
        #endif
    }

    #if canImport(UIKit)
    @MainActor
    private func render(_ view: AnyView, size: CGSize, dark: Bool, to url: URL) throws {
        let content = view
            .frame(width: size.width, height: size.height)
            .environment(\.colorScheme, dark ? .dark : .light)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 3
        // If dark renders ever look wrong, render through a UIHostingController with
        // overrideUserInterfaceStyle = .dark instead — ImageRenderer + environment is
        // usually enough for dynamic UIColor.
        guard let image = renderer.uiImage, let data = image.pngData() else {
            throw NSError(domain: "CosmiqueSnapshot", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to render \(url.lastPathComponent)"])
        }
        try data.write(to: url)
    }
    #endif

    /// .../CosmiquePreviews/Tests/SnapshotTests/SnapshotTests.swift → design-system/snapshots
    private static func snapshotDir() -> URL {
        var u = URL(filePath: #filePath)
        for _ in 0..<4 { u.deleteLastPathComponent() }
        return u.appending(path: "snapshots")
    }
}
