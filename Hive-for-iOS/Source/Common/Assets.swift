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
		static let joseph = UIImage(named: "Joseph")!
	}

	// MARK: - Colors

	enum Color {
		case primary
		case background
		case backgroundLight
		case backgroundDark

		case text
		case textSecondary

		var uiColor: UIColor {
			switch self {
			case .primary: return UIColor(named: "Primary")!
			case .background: return UIColor(named: "Background")!
			case .backgroundLight: return UIColor(named: "BackgroundLight")!
			case .backgroundDark: return UIColor(named: "BackgroundDark")!
			case .text: return UIColor(named: "Text")!
			case .textSecondary: return UIColor(named: "TextSecondary")!
			}
		}

		var color: SwiftUI.Color {
			return SwiftUI.Color(self.uiColor)
		}

		func withAlphaComponent(_ alpha: CGFloat) -> UIColor {
			return self.uiColor.withAlphaComponent(alpha)
		}
	}
}

extension SwiftUI.Color {
	static let primary = Assets.Color.primary.color
	static let background = Assets.Color.background.color
	static let backgroundDark = Assets.Color.backgroundDark.color
	static let backgroundLight = Assets.Color.backgroundLight.color
	static let text = Assets.Color.text.color
	static let textSecondary = Assets.Color.textSecondary.color
}

extension UIColor {
	var color: Color {
		return Color(self)
	}
}
