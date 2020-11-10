// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "myProject",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
      // 💧 A server-side Swift web framework.
      .package(url: "https://github.com/vapor/vapor.git", from: "4.32.0"),
      .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0-tau"),
      .package(url: "https://github.com/vapor/fluent", from: "4.0.0"),
      .package(url: "https://github.com/vapor/fluent-postgres-driver", from: "2.1.1"),
      .package(url: "https://github.com/lukaskubanek/LoremSwiftum", from: "2.2.1"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
              .product(name: "Leaf", package: "leaf"),
              .product(name: "Vapor", package: "vapor"),
              .product(name: "Fluent", package: "fluent"),
              .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
              .product(name: "LoremSwiftum", package: "LoremSwiftum"),
            ],
            swiftSettings: [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
