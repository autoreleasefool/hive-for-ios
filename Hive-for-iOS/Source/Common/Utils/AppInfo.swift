//
//  AppInfo.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-11-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

extension NSNotification.Name {
	enum AppInfo {
		static let Unsupported = Notification.Name("AppInfo.Unsupported")
	}
}

enum AppInfo {
	static var name: String {
		Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
	}

	static var versionString: String {
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
	}

	static var buildNumber: Int {
		Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-1") ?? -1
	}

	static var fullSemanticVersion: String {
		"\(versionString)+\(buildNumber)"
	}

	static var appStoreUrl: URL? {
		URL(string: "https://hive.josephroque.dev")
	}

	static func packageVersion(_ packageName: String) -> String {
		packages.first { $0.name == packageName }?.version ?? "None"
	}

	static let packages: [PackageDependency] = {
		guard let plistPath = Bundle.main.url(forResource: "Dependencies", withExtension: "plist"),
					let plistData = try? Data(contentsOf: plistPath),
					let packages = try? PropertyListSerialization.propertyList(
						from: plistData,
						options: [],
						format: nil
					) as? [String: Any] else {
			return []
		}

		return packages.map {
			PackageDependency(
				name: $0.key,
				version: ($0.value as? [String: String])?["version"] ?? "None"
			)
		}
	}()
}

// MARK: - Package

extension AppInfo {
	struct PackageDependency {
		let name: String
		let version: String
	}
}
