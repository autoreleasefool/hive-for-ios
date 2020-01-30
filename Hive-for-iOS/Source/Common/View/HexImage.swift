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

	init(url: URL?, placeholder: UIImage = UIImage(), stroke: ColorAsset = .primary) {
		self.url = url
		self.placeholder = placeholder
		self.stroke = stroke
	}

	init(_ image: UIImage, stroke: ColorAsset = .primary) {
		self.url = nil
		self.placeholder = image
		self.stroke = stroke
	}

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				RemoteImage(url: self.url, placeholder: self.placeholder)
					.aspectRatio(contentMode: .fit)
					.frame(width: self.imageWidth?.rawValue ?? geometry.size.width, height: self.imageHeight?.rawValue ?? geometry.size.height)
					.mask(Hex())
				Hex()
					.stroke(
						Color(self.stroke),
						lineWidth: min(geometry.size.width, geometry.size.height) * 0.075
					)
			}
		}
	}

	func innerImageFrame(width: Metrics.Image, height: Metrics.Image) -> Self {
		var hex = self
		hex.imageWidth = width
		hex.imageHeight = height
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
			HexImage(UIImage(systemName: "xmark")!, stroke: .primary)
				.innerImageFrame(width: .standard, height: .standard)
				.imageFrame(width: .large, height: .large)
			HexImage(ImageAsset.joseph, stroke: .primary)
				.imageFrame(width: .extraExtraLarge, height: .extraExtraLarge)
		}
	}
}
#endif
