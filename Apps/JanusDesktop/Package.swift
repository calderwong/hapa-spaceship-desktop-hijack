// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "JanusDesktop",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(path: "../../Packages/JanusEngine")
    ],
    targets: [
        .executableTarget(
            name: "JanusDesktop",
            dependencies: [
                .product(name: "JanusEngine", package: "JanusEngine")
            ],
            path: "Sources/JanusDesktop")
    ]
)
