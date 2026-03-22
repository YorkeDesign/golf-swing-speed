// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "GolfSwingSpeedApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "GolfSwingSpeedApp",
            targets: ["GolfSwingSpeedApp"]
        ),
    ],
    targets: [
        .target(
            name: "GolfSwingSpeedApp",
            path: "Sources/GolfSwingSpeedApp",
            resources: [
                .process("../../Resources")
            ]
        ),
        .testTarget(
            name: "GolfSwingSpeedAppTests",
            dependencies: ["GolfSwingSpeedApp"],
            path: "Tests/GolfSwingSpeedAppTests"
        ),
    ]
)
