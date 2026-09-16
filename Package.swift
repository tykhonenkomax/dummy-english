// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "WordTrainer",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "WordTrainer",
            path: "Sources/WordTrainer",
            resources: [.copy("Resources/bender.png"), .copy("Resources/logo.png")]
        )
    ]
)
