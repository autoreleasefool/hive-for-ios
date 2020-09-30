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
	enum Spacing {
		/// 40pt
		case xxl
		/// 32pt
		case xl
		/// 24pt
		case l
		/// 16pt
		case m
		/// 8pt
		case s
		/// 4pt
		case xs
		case custom(CGFloat)

		var rawValue: CGFloat {
			switch self {
			case .xxl: return 40
			case .xl:  return 32
			case .l:   return 24
			case .m:   return 16
			case .s:   return 8
			case .xs:  return 4
			case .custom(let value): return value
			}
		}

		static func + (lhs: Metrics.Spacing, rhs: Metrics.Spacing) -> Metrics.Spacing {
			.custom(lhs.rawValue + rhs.rawValue)
		}

		static func + (lhs: Metrics.Spacing, rhs: Metrics.Image) -> CGFloat {
			lhs.rawValue + rhs.rawValue
		}
	}
}

extension View {
	func frame(width: Metrics.Spacing, height: Metrics.Spacing) -> some View {
		frame(width: width.rawValue, height: height.rawValue)
	}

	func padding(_ length: Metrics.Spacing) -> some View {
		padding(length.rawValue)
	}

	func padding(_ edges: Edge.Set = .all, length: Metrics.Spacing) -> some View {
		padding(edges, length.rawValue)
	}
}

extension RoundedRectangle {
	init(cornerRadius: Metrics.Spacing) {
		self.init(cornerRadius: cornerRadius.rawValue)
	}
}

extension HStack {
	init(alignment: VerticalAlignment = .center, spacing: Metrics.Spacing, @ViewBuilder content: () -> Content) {
		self.init(alignment: alignment, spacing: spacing.rawValue, content: content)
	}
}

extension VStack {
	init(alignment: HorizontalAlignment = .center, spacing: Metrics.Spacing, @ViewBuilder content: () -> Content) {
		self.init(alignment: alignment, spacing: spacing.rawValue, content: content)
	}
}

// MARK: - Image

extension Metrics {
	enum Image {
		/// 128pt
		case xxl
		/// 64pt
		case xl
		/// 48pt
		case l
		/// 32pt
		case m
		/// 16pt
		case s
		case custom(CGFloat)

		var rawValue: CGFloat {
			switch self {
			case .xxl: return 128
			case .xl:  return 64
			case .l:   return 48
			case .m:   return 32
			case .s:   return 16
			case .custom(let value): return value
			}
		}

		static func + (lhs: Metrics.Image, rhs: Metrics.Image) -> Metrics.Image {
			.custom(lhs.rawValue + rhs.rawValue)
		}

		static func + (lhs: Metrics.Image, rhs: Metrics.Spacing) -> CGFloat {
			lhs.rawValue + rhs.rawValue
		}
	}
}

extension View {
	func squareImage(_ size: Metrics.Image) -> some View {
		frame(width: size.rawValue, height: size.rawValue)
	}

	func imageFrame(width: Metrics.Image, height: Metrics.Image) -> some View {
		frame(width: width.rawValue, height: height.rawValue)
	}
}
