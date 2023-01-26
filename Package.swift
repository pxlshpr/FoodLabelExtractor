// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FoodLabelExtractor",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FoodLabelExtractor",
            targets: ["FoodLabelExtractor"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pxlshpr/FoodLabelScanner", from: "0.0.132"),
        .package(url: "https://github.com/pxlshpr/PrepDataTypes", from: "0.0.244"),
        .package(url: "https://github.com/pxlshpr/PrepViews", from: "0.0.130"),
        .package(url: "https://github.com/pxlshpr/SwiftHaptics", from: "0.1.3"),
        .package(url: "https://github.com/pxlshpr/SwiftSugar", from: "0.0.86"),
        .package(url: "https://github.com/pxlshpr/SwiftUISugar", from: "0.0.323"),
        .package(url: "https://github.com/pxlshpr/VisionSugar", from: "0.0.77"),

        .package(url: "https://github.com/exyte/ActivityIndicatorView", from: "1.1.0"),
        .package(url: "https://github.com/markiv/SwiftUI-Shimmer", from: "1.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FoodLabelExtractor",
            dependencies: [
                .product(name: "FoodLabelScanner", package: "foodlabelscanner"),
                .product(name: "PrepDataTypes", package: "prepdatatypes"),
                .product(name: "PrepViews", package: "prepviews"),
                .product(name: "SwiftHaptics", package: "swifthaptics"),
                .product(name: "SwiftSugar", package: "swiftsugar"),
                .product(name: "SwiftUISugar", package: "swiftuisugar"),
                .product(name: "VisionSugar", package: "visionsugar"),
                
                .product(name: "ActivityIndicatorView", package: "activityindicatorview"),
                .product(name: "Shimmer", package: "swiftui-shimmer"),
            ]),
        .testTarget(
            name: "FoodLabelExtractorTests",
            dependencies: ["FoodLabelExtractor"]),
    ]
)
