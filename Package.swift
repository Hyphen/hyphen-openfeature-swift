// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Toggle",
    platforms: [.iOS(.v15), .macOS(.v14)],
    products: [
        .library(
            name: "Toggle",
            targets: ["Toggle"])
    ],
    dependencies: [
        .package(url: "https://github.com/open-feature/swift-sdk.git", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "Toggle",
            dependencies: [
                .product(name: "OpenFeature", package: "swift-sdk")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "ToggleTests",
            dependencies: [
                "Toggle",
                .product(name: "OpenFeature", package: "swift-sdk")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
