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
		UINavigationBar.appearance().backgroundColor = Assets.Color.primary.uiColor

		UITableView.appearance().backgroundColor = Assets.Color.background.uiColor
		UITableViewCell.appearance().backgroundColor = Assets.Color.background.uiColor
	}
}
