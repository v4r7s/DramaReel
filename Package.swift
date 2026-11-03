// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Dramareel",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "DramareelKit",
            targets: ["DramareelKit"]
        )
    ],
    dependencies: [
        // Firebase iOS SDK
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.8.0"),
        // Google Mobile Ads iOS SDK
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "11.13.0"),
        // OneSignal iOS SDK
        .package(url: "https://github.com/OneSignal/OneSignal-iOS-SDK.git", from: "5.2.7")
    ],
    targets: [
        .target(
            name: "DramareelKit",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
                .product(name: "OneSignalFramework", package: "OneSignal-iOS-SDK")
            ],
            path: "Dramareel"
        ),
        .testTarget(
            name: "DramareelTests",
            dependencies: ["DramareelKit"],
            path: "DramareelTests"
        )
    ]
)
