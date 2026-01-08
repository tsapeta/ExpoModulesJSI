// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ExpoModulesJSI",
  platforms: [
    .iOS("16.4")
  ],
  products: [
    .library(
      name: "ExpoModulesJSI",
      targets: ["ExpoModulesJSI"]
    ),
  ],
  dependencies: [],
  targets: [
    // Main, Swift-only target
    .target(
      name: "ExpoModulesJSI",
      dependencies: [
        "ExpoModulesJSI-Cxx",
        "jsi"
      ],
      cxxSettings: [
        .headerSearchPath("./Sources/jsi"),
      ],
      swiftSettings: [
        .interoperabilityMode(.Cxx)
      ],
    ),

    // C++ target
    .target(
      name: "ExpoModulesJSI-Cxx",
      dependencies: [
        "jsi"
      ],
      cxxSettings: [
        .headerSearchPath("./Sources/jsi"),
      ],
    ),

    // JSI headers
    .target(
      name: "jsi",
      dependencies: [],
    ),

    // Tests
    .testTarget(
      name: "ExpoModulesJSITests",
      dependencies: ["ExpoModulesJSI"],
      swiftSettings: [
        .interoperabilityMode(.Cxx)
      ],
    ),
  ],
  cxxLanguageStandard: .cxx20
)
