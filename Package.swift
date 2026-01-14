// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftShortcuts",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SwiftShortcuts",
            targets: ["SwiftShortcuts"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftShortcuts",
            exclude: ["Internal/ColorExtensions.md"]
        ),
        .executableTarget(
            name: "dump-glyphs",
            path: "Sources/dump-glyphs"
        ),
    ]
)
