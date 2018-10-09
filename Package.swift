// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "web3swift",
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(name: "web3swift", targets: ["web3swift"]),
    .executable(name: "web3app", targets: ["web3app"]),
    ],
  dependencies: [
    .package(url: "https://github.com/attaswift/BigInt.git", from: "3.1.0"),
    .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "0.12.0"),
    .package(url: "https://github.com/Boilertalk/secp256k1.swift.git", from: "0.1.1"),
    .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.4.0"),
    .package(url: "https://github.com/antitypical/Result.git", from: "4.0.0"),
    ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "web3swift",
      dependencies: ["BigInt", "CryptoSwift", "secp256k1", "PromiseKit", "Result"],
      path: "web3swift",
      exclude: [
        "Utils/Classes/EIP67Code.swift",
        "Info.plist",
        "webswift-Bridging-Header.h",
        "web3swift.h",
        ]),
    .target(name: "web3app", dependencies: ["web3swift"]),
    ]
)
