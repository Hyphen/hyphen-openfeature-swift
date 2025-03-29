// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Toggle",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Toggle",
            targets: ["Toggle"])
    ],
    dependencies: [
        .package(url: "https://github.com/open-feature/swift-sdk.git", from: "0.3.0"),
        .package(url: "https://github.com/fatbobman/SimpleLogger", .upToNextMajor(from: "0.1.2"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Toggle",
            dependencies: [
                .product(name: "OpenFeature", package: "swift-sdk"),
                .product(name: "SimpleLogger", package: "SimpleLogger")
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
