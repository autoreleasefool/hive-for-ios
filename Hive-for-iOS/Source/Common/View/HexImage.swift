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
					.frame(width: geometry.size.width, height: geometry.size.height)
					.mask(
						Hex()
							.frame(width: geometry.size.width, height: geometry.size.height)
					)
				Hex()
					.stroke(
						Color(self.stroke),
						lineWidth: min(geometry.size.width, geometry.size.height) * 0.075
					)
					.frame(width: geometry.size.width, height: geometry.size.height)
			}
		}
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
		HexImage(url: nil, placeholder: ImageAsset.joseph, stroke: .primary)
			.frame(width: 128, height: 128)
	}
}
#endif
