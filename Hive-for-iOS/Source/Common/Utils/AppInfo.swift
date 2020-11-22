//
//  AppInfo.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-11-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

enum AppInfo {
	static var name: String {
		Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
	}

	static var version: String {
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
	}

	static var build: Int {
		Int(Bundle.main.infoDictionary?[""] as? String ?? "-1") ?? -1
	}
}
