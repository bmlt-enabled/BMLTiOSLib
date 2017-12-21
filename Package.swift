// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
        4
    ]
)
