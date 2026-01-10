// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ExpoModulesJSI",
  platforms: [
    .iOS("16.4"),
    .tvOS("16.4"),
    .macOS("12.0"),
  ],
  products: [
    .library(
      name: "ExpoModulesJSI",
      type: .dynamic,
      targets: ["ExpoModulesJSI"],
    ),
  ],
  dependencies: [],
  targets: [
    // Swift target (public)
    .target(
      name: "ExpoModulesJSI",
      dependencies: [
        "ExpoModulesJSI-Cxx",
      ],
      cxxSettings: [
        .headerSearchPath("../jsi"),
      ],
      swiftSettings: [
        .interoperabilityMode(.Cxx),
        .unsafeFlags([
          "-enable-library-evolution",
          "-emit-module-interface",
          "-no-verify-emitted-module-interface",
          "-Xfrontend",
          "-clang-header-expose-decls=has-expose-attr",
        ])
      ],
      linkerSettings: [],
    ),

    // C++ target (internal)
    .target(
      name: "ExpoModulesJSI-Cxx",
      dependencies: [],
      cxxSettings: [
        .headerSearchPath("../jsi"),
      ],
      linkerSettings: [
        .unsafeFlags([
          "-Wl", "-undefined", "dynamic_lookup"
        ]),
      ],
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
