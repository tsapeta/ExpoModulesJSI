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
  targets: [
    .target(
      name: "ExpoModulesJSI",
      dependencies: [
        "ExpoModulesJSI-Cxx",
        "jsi",
      ],
      swiftSettings: [
        .interoperabilityMode(.Cxx)
      ],
      linkerSettings: [
        .unsafeFlags([
          // add has-expose-attr
        ])
      ],
    ),
    .target(
      name: "ExpoModulesJSI-Cxx",
      dependencies: [
        "jsi"
      ],
      cxxSettings: [
        .headerSearchPath("../jsi/include")
      ],
    ),
    .target(
      name: "jsi",
      cxxSettings: [],
    ),
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
