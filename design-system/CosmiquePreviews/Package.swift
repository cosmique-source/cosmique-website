// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CosmiquePreviews",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "CosmiqueUI", targets: ["CosmiqueUI"])
    ],
    targets: [
        .target(name: "CosmiqueUI", path: "Sources/CosmiqueUI"),
        .testTarget(name: "SnapshotTests", dependencies: ["CosmiqueUI"], path: "Tests/SnapshotTests")
    ]
)
