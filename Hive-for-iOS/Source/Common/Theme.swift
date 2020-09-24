//
//  Theme.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import UIKit
import SwiftyMarkdown

enum Theme {
	static func applyPrimaryTheme() {
		let coloredAppearance = UINavigationBarAppearance()
		coloredAppearance.configureWithOpaqueBackground()
		coloredAppearance.backgroundColor = UIColor(.highlightPrimary)
		coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
		coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

		UINavigationBar.appearance().standardAppearance = coloredAppearance
		UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
		UINavigationBar.appearance().tintColor = .white

		UITabBar.appearance().tintColor = UIColor(.highlightPrimary)

		UITableView.appearance().backgroundColor = UIColor(.backgroundRegular)
		UITableViewCell.appearance().backgroundColor = UIColor(.backgroundLight)

		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor(.backgroundRegular)
		UITableViewCell.appearance().selectedBackgroundView = backgroundView
	}

	static func applyMarkdownTheme(to markdown: SwiftyMarkdown) {
		markdown.body.color = UIColor(.textRegular)
		markdown.h1.color = UIColor(.textRegular)
		markdown.h2.color = UIColor(.textRegular)
		markdown.h3.color = UIColor(.textRegular)
		markdown.h4.color = UIColor(.textRegular)
		markdown.h5.color = UIColor(.textRegular)
		markdown.h6.color = UIColor(.textRegular)
		markdown.blockquotes.color = UIColor(.textRegular)
		markdown.code.color = UIColor(.textRegular)
		markdown.link.color = UIColor(.highlightPrimary)
	}
}
