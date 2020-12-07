//
//  Tooltip.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-12-06.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct Tooltip: View {
	private let title: String
	private var origin: CGPoint = .zero
	private var foregroundColor: ColorAsset = .textRegular
	private var backgroundColor: ColorAsset = .highlightPrimary

	init(_ title: String) {
		self.title = title
	}

	@ViewBuilder
	var body: some View {
		GeometryReader { geometry in
			VStack(spacing: 0) {
				if !indicatorPointingDown(in: geometry) {
					indicator(geometry)
				}

				Text(title)
					.font(.caption)
					.foregroundColor(foregroundColor)
					.padding()
					.background(
						RoundedRectangle(cornerRadius: .s)
							.fill(Color(backgroundColor))
					)

				if indicatorPointingDown(in: geometry) {
					indicator(geometry)
				}
			}
			.offset(
				y: origin.y < geometry.frame(in: .local).midY
					? origin.y + 64
					: origin.y - 64
			)
		}
	}

	private func indicator(_ geometry: GeometryProxy) -> some View {
		Indicator(pointingDown: indicatorPointingDown(in: geometry))
			.fill(Color(backgroundColor))
			.frame(width: 24, height: 12)
			.position(x: origin.x)
	}

	private func indicatorPointingDown(in geometry: GeometryProxy) -> Bool {
		origin.y > geometry.frame(in: .local).midY
	}
}

// MARK: - Indicator

extension Tooltip {
	fileprivate struct Indicator: Shape {
		let pointingDown: Bool

		func path(in rect: CGRect) -> Path {
			var path = Path()
			if pointingDown {
				path.move(to: rect.origin)
				path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
				path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
				path.addLine(to: rect.origin)
			} else {
				path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
				path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
				path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
				path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
			}
			return path
		}
	}
}

// MARK: - Modifiers

extension Tooltip {
	func originating(from origin: CGPoint) -> Self {
		var tooltip = self
		tooltip.origin = origin
		return tooltip
	}

	func foregroundColor(_ asset: ColorAsset) -> Self {
		var tooltip = self
		tooltip.foregroundColor = asset
		return tooltip
	}

	func backgroundColor(_ asset: ColorAsset) -> Self {
		var tooltip = self
		tooltip.backgroundColor = asset
		return tooltip
	}
}
