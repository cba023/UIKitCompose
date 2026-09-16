// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "UIKitCompose",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "UIKitCompose",
            targets: ["UIKitCompose"]),
        .library(
            name: "UIKitComposeDemos",
            targets: ["UIKitComposeDemos"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "6.0.0"),
    ],
    targets: [
        .target(
            name: "UIKitCompose",
            dependencies: ["SnapKit"]),
        .target(
            name: "UIKitComposeDemos",
            dependencies: [
                "UIKitCompose",
                "SnapKit",
            ]),
    ]
)
