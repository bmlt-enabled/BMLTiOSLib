import PackageDescription

let package = Package(
    name: "BMLTiOSLib",
    products: [
        .library(
            name: "BMLTiOSLib",
            targets: ["BMLTiOSLib"]
        )
    ],
    targets: [
        .target(
            name: "BMLTiOSLib",
            path: "BMLTiOSLib/Framework Project/Classes"
        )
    ],
    swiftLanguageVersions: [
        4.2
    ]
)
