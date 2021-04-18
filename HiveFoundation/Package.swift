// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "HiveFoundation",
	platforms: [
		.iOS("14.0"),
		.watchOS("7.2"),
	],
	products: [
		.library(
			name: "HiveFoundation",
			targets: ["HiveFoundation"]
		),
	],
	dependencies: [
		.package(name: "HiveEngine", url: "https://github.com/autoreleasefool/hive-engine.git", from: "3.1.2"),
	],
	targets: [
		.target(
			name: "HiveFoundation",
			dependencies: [
				.product(name: "HiveEngine", package: "HiveEngine"),
			]
		),
	]
)
