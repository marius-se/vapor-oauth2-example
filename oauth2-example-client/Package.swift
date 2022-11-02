// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "oauth2-example-client",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .executableTarget(name: "Run", dependencies: [.target(name: "App")])
    ]
)
