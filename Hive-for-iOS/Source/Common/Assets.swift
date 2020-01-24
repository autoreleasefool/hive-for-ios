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

	// MARK: - Colors

	enum Color {
		case primary
		case background

		case text
		case textSecondary

		var uiColor: UIColor {
			switch self {
			case .primary: return UIColor(named: "Primary")!
			case .background: return UIColor(named: "Background")!
			case .text: return UIColor(named: "Text")!
			case .textSecondary: return UIColor(named: "TextSecondary")!
			}
		}

		var color: SwiftUI.Color {
			return SwiftUI.Color(self.uiColor)
		}
	}
}

extension SwiftUI.Color {
	static let primary = Assets.Color.primary
	static let background = Assets.Color.background
	static let text = Assets.Color.text
	static let textSecondary = Assets.Color.textSecondary
}
