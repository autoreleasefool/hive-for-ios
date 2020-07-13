//
//  AnimatedEmoji.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-10.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct AnimateableEmoji: Equatable {
	let id = UUID()
	let emoji: Emoji
	let path: Path
	let duration: Double

	init(emoji: Emoji, geometry: GeometryProxy) {
		self.emoji = emoji
		self.path = AnimateableEmoji.generatePath(with: geometry)
		self.duration = Double.random(in: (1.5...2.5))
	}

	static func == (lhs: AnimateableEmoji, rhs: AnimateableEmoji) -> Bool {
		lhs.id == rhs.id
	}
}

struct AnimatedEmoji: View {
	let emoji: AnimateableEmoji
	let geometry: GeometryProxy

	@Binding private var isAnimating: Bool
	@State private var flag = false
	@State private var opacity: Double = 1

	init(emoji: AnimateableEmoji, isAnimating: Binding<Bool>, geometry: GeometryProxy) {
		self.emoji = emoji
		self.geometry = geometry
		self._isAnimating = isAnimating
	}

	var body: some View {
		Image(uiImage: emoji.emoji.image ?? UIImage())
			.resizable()
			.aspectRatio(contentMode: .fit)
			.squareImage(.l)
			.clipShape(Circle())
			.opacity(opacity)
			.modifier(FollowPathEffect(percent: self.flag ? 1 : 0, path: emoji.path))
			.onAppear {
				withAnimation(.easeInOut(duration: self.emoji.duration)) {
					self.opacity = 0
					self.flag.toggle()
				}

				DispatchQueue.main.asyncAfter(deadline: .now() + self.emoji.duration) {
					self.isAnimating = false
				}
			}
	}
}

// MARK: Path generation

extension AnimateableEmoji {
	static func generatePath(with geometry: GeometryProxy) -> Path {
		let endPoint = CGPoint(
			x: CGFloat.random(in: (-geometry.size.width / 4)...(geometry.size.width / 4)),
			y: CGFloat.random(in: (-geometry.size.height / 8)...(geometry.size.height / 8)) - geometry.size.height / 2
		)

		let animationWidth = geometry.size.width / 4 +
			CGFloat.random(in: -geometry.size.width / 8 ... geometry.size.width / 8)
		let widthModifier: CGFloat = Bool.random()
			? animationWidth
			: -animationWidth

		let control1 = CGPoint(x: endPoint.x * 2 - widthModifier, y: endPoint.y / 3)
		let control2 = CGPoint(x: endPoint.x * -2 + widthModifier, y: endPoint.y * (2 / 3))

		var path = Path()
		path.move(to: .zero)
		path.addCurve(to: endPoint, control1: control1, control2: control2)
		return path
	}
}

// MARK: FollowPath

/// https://swiftui-lab.com/swiftui-animations-part2/
struct FollowPathEffect: GeometryEffect {
	var percent: CGFloat = 0
	let path: Path

	var animatableData: CGFloat {
		get { percent }
		set { percent = newValue }
	}

	func effectValue(size: CGSize) -> ProjectionTransform {
		let pt = percentPoint(percent)
		return ProjectionTransform(CGAffineTransform(translationX: pt.x, y: pt.y))
	}

	private func percentPoint(_ percent: CGFloat) -> CGPoint {
		let diff: CGFloat = 0.001
		let comp: CGFloat = 1 - diff

		let pct = percent > 1 ? 0 : (percent < 0 ? 1 : percent)
		let f = pct > comp ? comp : pct
		let t = pct > comp ? 1 : pct + diff
		let tp = path.trimmedPath(from: f, to: t)

		return CGPoint(x: tp.boundingRect.midX, y: tp.boundingRect.midY)
	}
}
