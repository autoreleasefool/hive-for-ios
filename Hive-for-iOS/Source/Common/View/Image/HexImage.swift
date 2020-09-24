//
//  HexImage.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-25.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct HexImage: View {
	private let url: URL?
	private let placeholder: UIImage
	private let stroke: ColorAsset
	private var imageWidth: Metrics.Image?
	private var imageHeight: Metrics.Image?
	private var placeholderTint: ColorAsset?

	init(url: URL?, placeholder: UIImage = UIImage(), stroke: ColorAsset = .highlightPrimary) {
		self.url = url
		self.placeholder = placeholder
		self.stroke = stroke
	}

	init(_ image: UIImage, stroke: ColorAsset = .highlightPrimary) {
		self.url = nil
		self.placeholder = image
		self.stroke = stroke
	}

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				RemoteImage(url: self.url, placeholder: self.placeholder)
					.placeholderTint(self.placeholderTint)
					.frame(
						width: self.imageWidth?.rawValue ?? geometry.size.width,
						height: self.imageHeight?.rawValue ?? geometry.size.height
					)
					.mask(
						Hex()
							.frame(width: geometry.size.width, height: geometry.size.height)
							.scaledToFill()
					)
				Hex()
					.stroke(
						Color(self.stroke),
						lineWidth: min(geometry.size.width, geometry.size.height) * 0.075
					)
			}
		}
	}

	func squareInnerImage(_ size: Metrics.Image) -> Self {
		innerImageFrame(width: size, height: size)
	}

	func innerImageFrame(width: Metrics.Image, height: Metrics.Image) -> Self {
		var hex = self
		hex.imageWidth = width
		hex.imageHeight = height
		return hex
	}

	func placeholderTint(_ asset: ColorAsset) -> Self {
		var hex = self
		hex.placeholderTint = asset
		return hex
	}
}

struct Hex: Shape {
	func path(in rect: CGRect) -> Path {
		let hypotenuse = min(rect.width, rect.height) / 2
		let center = CGPoint(x: rect.width / 2, y: rect.height / 2)

		var path = Path()

		for vertex in 0..<6 {
			let angle = CGFloat(vertex) * CGFloat.pi / 3 + CGFloat.pi / 6

			let nextVertex = CGPoint(
				x: center.x + cos(angle) * hypotenuse,
				y: center.y + sin(angle) * hypotenuse
			)

			if path.currentPoint == nil {
				path.move(to: nextVertex)
			} else {
				path.addLine(to: nextVertex)
			}
		}

		path.closeSubpath()
		return path
	}
}

#if DEBUG
struct HexImagePreview: PreviewProvider {
	static var previews: some View {
		VStack {
			HexImage(ImageAsset.Icon.handFilled, stroke: .highlightPrimary)
				.placeholderTint(.highlightPrimary)
				.squareInnerImage(.m)
				.squareImage(.l)
			HexImage(ImageAsset.Icon.close, stroke: .highlightPrimary)
				.squareInnerImage(.s)
				.squareImage(.l)
			HexImage(ImageAsset.joseph, stroke: .highlightPrimary)
				.imageFrame(width: .xxl, height: .xxl)
		}
	}
}
#endif
