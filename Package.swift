// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SFSymbols",
    platforms: [
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .iOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SFSymbols",
            targets: ["SFSymbols"]
        )
    ],
    targets: [
        .target(
            name: "SFSymbols"
        ),
        .testTarget(
            name: "SFSymbolsTests",
            dependencies: ["SFSymbols"]
        )
    ]
)
