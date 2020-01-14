//
//  Assets.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import UIKit

enum Assets {

	// MARK: - Images

	enum Image {
		static let glyph = UIImage(named: "Glyph")!
	}

	// MARK - Colors

	enum Color {
		static let primary = SwiftUI.Color(UIColor(named: "Primary")!)
		static let background = SwiftUI.Color(UIColor(named: "Background")!)

		static let text = SwiftUI.Color(UIColor(named: "Text")!)
		static let textSecondary = SwiftUI.Color(UIColor(named: "TextSecondary")!)
	}
}

extension SwiftUI.Color {
	static let primary = Assets.Color.primary
	static let background = Assets.Color.background
	static let text = Assets.Color.text
	static let textSecondary = Assets.Color.textSecondary
}
