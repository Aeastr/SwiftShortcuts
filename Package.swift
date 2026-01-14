// swift-tools-version: 6.0
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
    dependencies: [
        .package(url: "https://github.com/Aeastr/Conditionals.git", .upToNextMajor(from: "1.2.3")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "SwiftShortcuts",
            dependencies: [
                .product(name: "Conditionals", package: "Conditionals"),
            ],
            exclude: ["Extensions/ColorExtensions.md"]
        ),
        .executableTarget(
            name: "sstools",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/sstools"
        ),
        .testTarget(
            name: "SwiftShortcutsTests",
            dependencies: ["SwiftShortcuts"]
        ),
    ]
)
