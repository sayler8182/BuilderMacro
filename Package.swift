// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

// swiftlint:disable:next prefixed_toplevel_constant
let package = Package(
    name: "BuilderMacro",
    platforms: [.iOS(.v14), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BuilderMacro",
            type: .dynamic,
            targets: ["BuilderMacro"]
        ),
        .executable(
            name: "BuilderMacroClient",
            targets: ["BuilderMacroClient"]
        )
    ],
    dependencies: [
        // Depend on the latest Swift 5.9 prerelease of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "BuilderMacroMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "BuilderMacroMacros"
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "BuilderMacro",
            dependencies: ["BuilderMacroMacros"],
            path: "BuilderMacro"),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "BuilderMacroClient",
            dependencies: ["BuilderMacro"],
            path: "BuilderMacroClient"),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "BuilderMacroTests",
            dependencies: [
                "BuilderMacroMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ],
            path: "BuilderMacroTests"
        )
    ]
)
