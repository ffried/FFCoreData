// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FFCoreData",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12),
        .watchOS(.v4),
        .tvOS(.v10),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "FFCoreData", targets: ["FFCoreData"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ffried/FFFoundation.git", from: "7.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "FFCoreData",
            dependencies: ["FFFoundation"],
            exclude: ["Supporting Files"]),
        .testTarget(
            name: "FFCoreDataTests",
            dependencies: ["FFCoreData"],
            exclude: ["Supporting Files"]),
    ]
)
