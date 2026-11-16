// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BingoghData",
    platforms: [.iOS("18.0"), .macOS("15.0")],
    products: [
        .library(name: "BingoghData", targets: ["BingoghData"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.0")
    ],
    targets: [
        .target(
            name: "BingoghData",
            dependencies: [.product(name: "Alamofire", package: "Alamofire")]
        ),
        .testTarget(
            name: "BingoghDataTests",
            dependencies: ["BingoghData"]
        )
    ],
    swiftLanguageModes: [.v6]
)
