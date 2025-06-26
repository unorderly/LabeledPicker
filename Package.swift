// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "LabeledPicker",
                      platforms: [
                          .iOS(.v17), .watchOS(.v10), .macCatalyst(.v17), .macOS(.v14)
                      ],
                      products: [
                          .library(name: "LabeledPicker",
                                   targets: ["LabeledPicker"])
                      ],
                      targets: [
                          .target(name: "LabeledPicker",
                                  dependencies: [])
                      ])
