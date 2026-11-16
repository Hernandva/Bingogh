// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BingoghUI",
    defaultLocalization: "en",
    platforms: [.iOS("18.0"), .macOS("15.0")],
    products: [
        .library(name: "BingoghUI", targets: ["BingoghUI"])
    ],
    targets: [
        .target(
            name: "BingoghUI",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "BingoghUITests",
            dependencies: ["BingoghUI"]
        )
    ],
    swiftLanguageModes: [.v6]
)
