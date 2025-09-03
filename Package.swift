// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ReduxSwiftUIDemo",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.15.0"
        )
    ],
    targets: [
        .target(
            name: "ReduxSwiftUIDemo",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "ReduxSwiftUIDemo"
        )
    ]
)