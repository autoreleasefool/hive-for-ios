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
		coloredAppearance.backgroundColor = UIColor(.primary)
		coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
		coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

		UINavigationBar.appearance().standardAppearance = coloredAppearance
		UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
		UINavigationBar.appearance().tintColor = .white

		UITabBar.appearance().tintColor = UIColor(.primary)

		UITableView.appearance().backgroundColor = UIColor(.background)
		UITableViewCell.appearance().backgroundColor = UIColor(.backgroundLight)

		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor(.background)
		UITableViewCell.appearance().selectedBackgroundView = backgroundView
	}

	static func applyMarkdownTheme(to markdown: SwiftyMarkdown) {
		markdown.body.color = UIColor(.text)
		markdown.h1.color = UIColor(.text)
		markdown.h2.color = UIColor(.text)
		markdown.h3.color = UIColor(.text)
		markdown.h4.color = UIColor(.text)
		markdown.h5.color = UIColor(.text)
		markdown.h6.color = UIColor(.text)
		markdown.blockquotes.color = UIColor(.text)
		markdown.code.color = UIColor(.text)
		markdown.link.color = UIColor(.primary)
	}
}
