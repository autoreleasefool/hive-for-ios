//
//  AppVersionUnsupportedView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-11-23.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct AppVersionUnsupportedView: View {
	var body: some View {
		EmptyState(
			header: "App version unsupported",
			message: """
			The version of the app you're using (\(AppInfo.fullSemanticVersion)) is no longer supported.
			Please visit the app store to download the latest version.
			""",
			action: EmptyState.Action(text: "Open App Store") {
				guard let appStoreUrl = AppInfo.appStoreUrl,
							UIApplication.shared.canOpenURL(appStoreUrl) else { return }
				UIApplication.shared.open(appStoreUrl)
			}
		)
	}
}
