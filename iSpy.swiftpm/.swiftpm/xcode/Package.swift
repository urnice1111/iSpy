// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(name: "MyApp", targets: ["AppModule"])
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .process("Media.xcassets")
            ]
        )
    ]
)
