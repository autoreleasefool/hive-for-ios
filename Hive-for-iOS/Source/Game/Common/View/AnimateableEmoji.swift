//
//  AnimateableEmoji.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-12-08.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct AnimateableEmoji: Equatable {
	let id = UUID()
	let emoji: Emoji
	let image: UIImage
	let shouldEaseInOut: Bool

	let path: Path
	let initialDelay: Double
	let duration: Double
	let scale: (start: CGFloat, end: CGFloat)
	let rotationSpeed: EmojiRotationSpeed

	var totalDuration: Double {
		initialDelay + duration
	}

	init(emoji: Emoji, image: UIImage, geometry: GeometryProxy) {
		self.emoji = emoji
		self.image = image
		self.path = emoji.generatePath(with: geometry)
		self.initialDelay = emoji.initialDelay()
		self.duration = emoji.randomDuration()
		self.scale = emoji.scale()
		self.rotationSpeed = emoji.rotationSpeed()
		self.shouldEaseInOut = emoji.shouldEaseInOut()
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
	@State private var scale: CGFloat = 1

	init(emoji: AnimateableEmoji, isAnimating: Binding<Bool>, geometry: GeometryProxy) {
		self.emoji = emoji
		self.geometry = geometry
		self._isAnimating = isAnimating
		self.scale = emoji.scale.start
	}

	var body: some View {
		Image(uiImage: emoji.image)
			.resizable()
			.aspectRatio(contentMode: .fit)
			.squareImage(.l)
			.opacity(opacity)
			.scaleEffect(scale)
			.rotationEffect(.degrees(flag ? 0 : emoji.rotationSpeed.revolutions * 360))
			.modifier(FollowPathEffect(percent: flag ? 1 : 0, path: emoji.path))
			.onAppear {
				withAnimation(
					emoji.shouldEaseInOut
						? Animation.easeInOut(duration: emoji.duration).delay(emoji.initialDelay)
						: Animation.linear(duration: emoji.duration).delay(emoji.initialDelay)
				) {
					flag.toggle()
				}
				withAnimation(Animation.linear(duration: 1).delay(emoji.totalDuration - 1)) {
					opacity = 0
				}
				withAnimation(Animation.linear(duration: 0.5).delay(emoji.totalDuration - 0.5)) {
					scale = emoji.scale.end
				}

				DispatchQueue.main.asyncAfter(deadline: .now() + emoji.totalDuration) {
					isAnimating = false
				}
			}
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
