//
//  Assets.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import UIKit

// MARK: - Images

enum ImageAsset {
	static let glyph = UIImage(named: "Glyph")!
	static let joseph = UIImage(named: "Joseph")!
	static let borderlessGlyph = UIImage(named: "Icons/BorderlessGlyph")!

	enum Icon {
		static let handFilled = UIImage(named: "Icons/Hand.Filled")!
		static let handOutlined = UIImage(named: "Icons/Hand.Outlined")!
		static let close = UIImage(named: "Icons/Close")!
		static let info = UIImage(named: "Icons/Info")!
		static let smiley = UIImage(named: "Icons/Smiley")!
	}

	enum Movement {
		static let move = UIImage(named: "Movement/Move")!
		static let place = UIImage(named: "Movement/Place")!
		static let yoink = UIImage(named: "Movement/Yoink")!
		static let pass = UIImage(named: "Movement/Pass")!
	}

	enum Pieces {
		static let blank = UIImage(named: "Pieces/Blank")!
		static let ant = UIImage(named: "Pieces/Ant")!
		static let beetle = UIImage(named: "Pieces/Beetle")!
		static let hopper = UIImage(named: "Pieces/Hopper")!
		static let ladyBug = UIImage(named: "Pieces/Lady Bug")!
		static let mosquito = UIImage(named: "Pieces/Mosquito")!
		static let pillBug = UIImage(named: "Pieces/Pill Bug")!
		static let queen = UIImage(named: "Pieces/Queen")!
		static let spider = UIImage(named: "Pieces/Spider")!
	}

	enum EmptyState { }
}

// MARK: - Colors

enum ColorAsset: String {
	case backgroundRegular = "Colors/Background"
	case backgroundLight = "Colors/BackgroundLight"
	case backgroundDark = "Colors/BackgroundDark"

	case highlightPrimary = "Colors/Primary"
	case highlightRegular = "Colors/Highlight"
	case highlightDestructive = "Colors/Destructive"
	case highlightSuccess = "Colors/Success"

	case textRegular = "Colors/Text/Text"
	case textSecondary = "Colors/Text/TextSecondary"
	case textContrasting = "Colors/Text/TextContrasting"
	case textContrastingSecondary = "Colors/Text/TextContrastingSecondary"

	case textField = "Colors/Text/TextField"

	case dividerRegular = "Colors/Divider"

	case actionSheetBackground = "Colors/ActionSheet"

	case clear = "Colors/Clear"
	case white = "Colors/White"
}

extension UIColor {
	convenience init(_ asset: ColorAsset) {
		self.init(named: asset.rawValue)!
	}
}

extension Color {
	init(_ asset: ColorAsset) {
		self.init(UIColor(asset))
	}
}
