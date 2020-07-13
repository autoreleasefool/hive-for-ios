//
//  AnimatedEmoji.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-10.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct AnimateableEmoji: Equatable {
	enum Source {
		case picked
		case fromOpponent
	}

	let emoji: Emoji
	let source: Source
	let id = UUID()
}

struct AnimatedEmoji: View {
	private static let animationDuration: Double = 2

	let emoji: AnimateableEmoji
	let geometry: GeometryProxy

	private let endOffset: CGSize

	@Binding private var isAnimating: Bool
	@State private var opacity: Double = 1
	@State private var offset: CGSize = .zero

	init(emoji: AnimateableEmoji, isAnimating: Binding<Bool>, geometry: GeometryProxy) {
		self.emoji = emoji
		self.geometry = geometry
		self.endOffset = CGSize(
			width: CGFloat.random(in: (-geometry.size.width / 4)...(geometry.size.width / 4)),
			height: CGFloat.random(in: (-geometry.size.height / 8)...(geometry.size.height / 8)) - geometry.size.height / 2
		)
		self._isAnimating = isAnimating
	}

	var body: some View {
		Image(uiImage: emoji.emoji.image ?? UIImage())
			.resizable()
			.aspectRatio(contentMode: .fit)
			.squareImage(.l)
			.clipShape(Circle())
			.offset(offset)
			.opacity(opacity)
			.onAppear {
				withAnimation(.spring()) {
					self.offset = self.endOffset
					self.opacity = 0
				}

				DispatchQueue.main.asyncAfter(deadline: .now() + AnimatedEmoji.animationDuration) {
					self.isAnimating = false
				}
			}
	}
}
