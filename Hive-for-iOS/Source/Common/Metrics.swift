//
//  Metrics.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

enum Metrics { }

// MARK: - Spacing

extension Metrics {
	enum Spacing: CGFloat {
		case extraLarge = 64
		case large      = 32
		case standard   = 16
		case small      = 8
		case extraSmall = 4
	}
}

extension View {
	func frame(width: Metrics.Spacing, height: Metrics.Spacing) -> some View {
		return frame(width: width.rawValue, height: height.rawValue)
	}

	func padding(_ length: Metrics.Spacing) -> some View {
		return padding(length.rawValue)
	}

	func padding(_ edges: Edge.Set = .all, _ length: Metrics.Spacing? = nil) -> some View {
		return padding(edges, length?.rawValue)
	}
}

// MARK: - Image

extension Metrics {
	enum Image: CGFloat {
		case extraExtraLarge = 128
		case extraLarge      = 64
		case large           = 48
		case standard        = 32
		case small           = 16
	}
}

extension HexImage {
	func imageFrame(width: Metrics.Image, height: Metrics.Image) -> some View {
		return frame(width: width.rawValue, height: height.rawValue)
	}
}

extension Image {
	func imageFrame(width: Metrics.Image, height: Metrics.Image) -> some View {
		return frame(width: width.rawValue, height: height.rawValue)
	}
}

// MARK: - Text

extension Metrics {
	enum Text: CGFloat {
		case title    = 32
		case subtitle = 24
		case body     = 16
		case caption  = 12
	}
}

extension View {
	func title() -> some View {
		return self.font(.system(size: Metrics.Text.title.rawValue))
	}

	func subtitle() -> some View {
		return self.font(.system(size: Metrics.Text.subtitle.rawValue))
	}

	func body() -> some View {
		return self.font(.system(size: Metrics.Text.body.rawValue))
	}

	func caption() -> some View {
		return self.font(.system(size: Metrics.Text.caption.rawValue))
	}
}
