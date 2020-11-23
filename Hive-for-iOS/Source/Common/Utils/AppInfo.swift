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
		"\(AppInfo.versionString)+\(AppInfo.buildNumber)"
	}

	static var appStoreUrl: URL? {
		URL(string: "https://hive.josephroque.dev")
	}
}
