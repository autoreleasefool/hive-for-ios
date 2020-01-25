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
		coloredAppearance.backgroundColor = Assets.Color.primary.uiColor
		coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
		coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

		UINavigationBar.appearance().standardAppearance = coloredAppearance
		UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
		UINavigationBar.appearance().tintColor = .white

		UITableView.appearance().backgroundColor = Assets.Color.background.uiColor
		UITableViewCell.appearance().backgroundColor = Assets.Color.backgroundLight.uiColor

		let backgroundView = UIView()
		backgroundView.backgroundColor = Assets.Color.background.uiColor
		UITableViewCell.appearance().selectedBackgroundView = backgroundView
	}
}
