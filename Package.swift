// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ArduinoProgrammer",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ArduinoProgrammer",
            targets: ["ArduinoProgrammer"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ArduinoProgrammer",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "ArduinoProgrammerTests",
            dependencies: ["ArduinoProgrammer"],
            path: "Tests"),
    ]
)
