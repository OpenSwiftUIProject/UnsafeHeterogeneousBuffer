// swift-tools-version: 6.0

import PackageDescription

func envEnable(_ key: String, default defaultValue: Bool = false) -> Bool {
    guard let value = Context.environment[key] else {
        return defaultValue
    }
    if value == "1" {
        return true
    } else if value == "0" {
        return false
    } else {
        return defaultValue
    }
}

let testTarget = Target.testTarget(name: "UnsafeHeterogeneousBufferTests")
var platforms: [SupportedPlatform]?

let compatibilityTestCondition = envEnable("UNSAFEHETEROGENEOUSBUFFER_SWIFTUI_COMPATIBILITY_TEST")
if compatibilityTestCondition {
    var swiftSettings: [SwiftSetting] = (testTarget.swiftSettings ?? [])
    swiftSettings.append(.define("UNSAFEHETEROGENEOUSBUFFER_SWIFTUI_COMPATIBILITY_TEST"))
    testTarget.swiftSettings = swiftSettings
    platforms = [.iOS(.v18), .macOS(.v15), .tvOS(.v18), .watchOS(.v11), .visionOS(.v2)]
} else {
    testTarget.dependencies.append("UnsafeHeterogeneousBuffer")
}

let libraryType: Product.Library.LibraryType?
switch Context.environment["UNSAFEHETEROGENEOUSBUFFER_LIBRARY_TYPE"] {
case "dynamic":
    libraryType = .dynamic
case "static":
    libraryType = .static
default:
    libraryType = nil
}

let package = Package(
    name: "UnsafeHeterogeneousBuffer",
    platforms: platforms,
    products: [
        .library(name: "UnsafeHeterogeneousBuffer", type: libraryType, targets: ["UnsafeHeterogeneousBuffer"]),
    ],
    targets: [
        .target(
            name: "UnsafeHeterogeneousBuffer",
            swiftSettings: [
                .enableUpcomingFeature("InternalImportsByDefault"),
            ]
        ),
        testTarget,
    ]
)
