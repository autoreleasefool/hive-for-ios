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
}

// MARK: - Colors

enum ColorAsset: String {
	case primary = "Primary"
	case background = "Background"
	case backgroundLight = "BackgroundLight"
	case backgroundDark = "BackgroundDark"

	case text = "Text"
	case textSecondary = "TextSecondary"

	case separator = "Separator"

	case clear = "Clear"
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
