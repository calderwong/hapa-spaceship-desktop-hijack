// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "JanusEngine",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "JanusEngine",
            targets: ["JanusEngine"]),
    ],
    targets: [
        .target(
            name: "JanusEngine",
            dependencies: [],
            path: "Sources/JanusEngine",
            resources: [
                .process("Shaders")
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include")
            ],
            cxxSettings: [
                .headerSearchPath("include")
            ]),
        .testTarget(
            name: "JanusEngineTests",
            dependencies: ["JanusEngine"]),
    ]
)
