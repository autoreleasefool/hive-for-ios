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
	#if os(iOS)
	static let glyph = UIImage(named: "Glyph")!
	static let joseph = UIImage(named: "Joseph")!
	static let borderlessGlyph = UIImage(named: "Icons/BorderlessGlyph")!
	#endif

	#if os(iOS)
	enum Icon {
		static let handFilled = UIImage(named: "Icons/Hand.Filled")!
		static let handOutlined = UIImage(named: "Icons/Hand.Outlined")!
		static let close = UIImage(named: "Icons/Close")!
		static let info = UIImage(named: "Icons/Info")!
		static let smiley = UIImage(named: "Icons/Smiley")!
	}
	#endif

	enum Movement {
		static let move = UIImage(named: "Movement/Move")!
		static let place = UIImage(named: "Movement/Place")!
		static let yoink = UIImage(named: "Movement/Yoink")!
		static let pass = UIImage(named: "Movement/Pass")!
	}

	enum Pieces {
		static let blank = UIImage(named: "Pieces/Blank")!

		enum White {
			enum Filled {
				static let ant = UIImage(named: "Pieces/White/Filled/Ant")!
				static let beetle = UIImage(named: "Pieces/White/Filled/Beetle")!
				static let hopper = UIImage(named: "Pieces/White/Filled/Hopper")!
				static let ladyBug = UIImage(named: "Pieces/White/Filled/Lady Bug")!
				static let mosquito = UIImage(named: "Pieces/White/Filled/Mosquito")!
				static let pillBug = UIImage(named: "Pieces/White/Filled/Pill Bug")!
				static let queen = UIImage(named: "Pieces/White/Filled/Queen")!
				static let spider = UIImage(named: "Pieces/White/Filled/Spider")!
			}

			static let ant = UIImage(named: "Pieces/White/Ant")!
			static let beetle = UIImage(named: "Pieces/White/Beetle")!
			static let hopper = UIImage(named: "Pieces/White/Hopper")!
			static let ladyBug = UIImage(named: "Pieces/White/Lady Bug")!
			static let mosquito = UIImage(named: "Pieces/White/Mosquito")!
			static let pillBug = UIImage(named: "Pieces/White/Pill Bug")!
			static let queen = UIImage(named: "Pieces/White/Queen")!
			static let spider = UIImage(named: "Pieces/White/Spider")!
		}

		enum Black {
			enum Filled {
				static let ant = UIImage(named: "Pieces/Black/Filled/Ant")!
				static let beetle = UIImage(named: "Pieces/Black/Filled/Beetle")!
				static let hopper = UIImage(named: "Pieces/Black/Filled/Hopper")!
				static let ladyBug = UIImage(named: "Pieces/Black/Filled/Lady Bug")!
				static let mosquito = UIImage(named: "Pieces/Black/Filled/Mosquito")!
				static let pillBug = UIImage(named: "Pieces/Black/Filled/Pill Bug")!
				static let queen = UIImage(named: "Pieces/Black/Filled/Queen")!
				static let spider = UIImage(named: "Pieces/Black/Filled/Spider")!
			}

			static let ant = UIImage(named: "Pieces/Black/Ant")!
			static let beetle = UIImage(named: "Pieces/Black/Beetle")!
			static let hopper = UIImage(named: "Pieces/Black/Hopper")!
			static let ladyBug = UIImage(named: "Pieces/Black/Lady Bug")!
			static let mosquito = UIImage(named: "Pieces/Black/Mosquito")!
			static let pillBug = UIImage(named: "Pieces/Black/Pill Bug")!
			static let queen = UIImage(named: "Pieces/Black/Queen")!
			static let spider = UIImage(named: "Pieces/Black/Spider")!
		}
	}

	#if os(iOS)
	enum EmptyState { }
	#endif
}

// MARK: - Colors

enum ColorAsset: String {
	case backgroundRegular = "Colors/Background"
	case backgroundLight = "Colors/BackgroundLight"
	case backgroundDark = "Colors/BackgroundDark"

	case highlightPrimaryTransparent = "Colors/PrimaryTransparent"
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
	case whiteTransparent = "Colors/WhiteTransparent"
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

extension View {
	func foregroundColor(_ asset: ColorAsset) -> some View {
		self.foregroundColor(Color(asset))
	}

	func backgroundColor(_ asset: ColorAsset) -> some View {
		self.background(Color(asset))
	}
}
