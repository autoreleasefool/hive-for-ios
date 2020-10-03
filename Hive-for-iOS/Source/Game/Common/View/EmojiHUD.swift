//
//  EmojiHUD.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-08.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct EmojiHUD: View {
	private static let width: CGFloat = 80

	@EnvironmentObject private var viewModel: GameViewModel

	private var pickerOffset: CGFloat {
		viewModel.showingEmojiPicker
			? Metrics.Spacing.m.rawValue
			: -EmojiHUD.width
	}

	@State private var animatingEmoji: [AnimateableEmoji] = []

	var body: some View {
		ZStack {
			self.animatedEmoji
			self.picker
		}
	}

	// MARK: - Animations

	private var animatedEmoji: some View {
		GeometryReader { geometry in
			ZStack {
				ForEach(animatingEmoji, id: \.id) { emoji in
					AnimatedEmoji(emoji: emoji, isAnimating: isAnimating(emoji), geometry: geometry)
						.position(x: geometry.size.width / 2, y: geometry.size.height)
				}
			}
			.frame(width: geometry.size.width, height: geometry.size.height)
			.onReceive(viewModel.animatedEmoji) { emoji in
				let animations = (0...Int.random(in: (15...20))).map { _ in AnimateableEmoji(emoji: emoji, geometry: geometry) }
				animatingEmoji.append(contentsOf: animations)
			}
		}
	}

	private func isAnimating(_ emoji: AnimateableEmoji) -> Binding<Bool> {
		Binding(
			get: { animatingEmoji.contains(emoji) },
			set: { newValue in
				guard !newValue, let index = animatingEmoji.firstIndex(of: emoji) else { return }
				animatingEmoji.remove(at: index)
			}
		)
	}

	// MARK: - Picker

	private var picker: some View {
		GeometryReader { geometry in
			Group {
				VStack(alignment: .center, spacing: .m) {
					ForEach(Emoji.allCases.indices) { index in
						Button {
							viewModel.postViewAction(.pickedEmoji(Emoji.allCases[index]))
						} label: {
							Image(uiImage: Emoji.allCases[index].image ?? UIImage())
								.resizable()
								.aspectRatio(contentMode: .fit)
								.squareImage(.l)
								.clipShape(Circle())
						}
					}
				}
				.padding(.vertical)
				.frame(width: EmojiHUD.width, alignment: .top)
				.background(Color(.actionSheetBackground))
				.cornerRadius(EmojiHUD.width / 2)
				.animation(.interactiveSpring())
				.offset(x: pickerOffset)
			}
			.offset(x: -geometry.size.width / 2 + EmojiHUD.width / 2)
		}
	}
}

#if DEBUG
struct EmojiHUDPreview: PreviewProvider {
	static var previews: some View {
		EmojiHUD()
	}
}
#endif
