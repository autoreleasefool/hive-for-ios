//
//  Theme.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import UIKit

enum Theme {
	static func applyPrimaryTheme() {
		let coloredAppearance = UINavigationBarAppearance()
		coloredAppearance.configureWithOpaqueBackground()
		coloredAppearance.backgroundColor = UIColor(ColorAsset.primary)
		coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
		coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

		UINavigationBar.appearance().standardAppearance = coloredAppearance
		UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
		UINavigationBar.appearance().tintColor = .white

		UITableView.appearance().backgroundColor = UIColor(ColorAsset.background)
		UITableViewCell.appearance().backgroundColor = UIColor(ColorAsset.backgroundLight)

		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor(ColorAsset.background)
		UITableViewCell.appearance().selectedBackgroundView = backgroundView
	}
}
