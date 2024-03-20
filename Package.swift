// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InAppPurchaseKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .tvOS(.v15),
        .visionOS(.v1),
        .watchOS(.v8)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "InAppPurchaseKit",
            targets: ["InAppPurchaseKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/adamfootdev/HapticsKit", from: "1.0.0"),
        .package(url: "https://github.com/adamfootdev/TPInAppReceipt", from: "3.4.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "InAppPurchaseKit",
            dependencies: [
                .product(name: "HapticsKit", package: "hapticskit"),
                .product(name: "TPInAppReceipt", package: "tpinappreceipt")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "InAppPurchaseKitTests",
            dependencies: ["InAppPurchaseKit"]),
    ]
)
