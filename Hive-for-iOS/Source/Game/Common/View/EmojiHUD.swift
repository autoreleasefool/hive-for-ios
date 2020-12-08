//
//  EmojiHUD.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-10-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct EmojiHUD: View {
	private static let width: CGFloat = 80

	@EnvironmentObject private var viewModel: GameViewModel

	private var pickerOffset: CGFloat {
		viewModel.isShowingEmojiPicker
			? Metrics.Spacing.m.rawValue
			: -EmojiHUD.width
	}

	@State private var animatingEmoji: [AnimateableEmoji] = []

	var body: some View {
		ZStack {
			animatedEmoji
			picker
		}
	}

	// MARK: Animations

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
				let animations = (0...Int.random(in: 15...20))
					.map { _ in
						AnimateableEmoji(
							emoji: emoji,
							image: emoji.image,
							geometry: geometry)
					}
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

	// MARK: Picker

	private var picker: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: $viewModel.isShowingEmojiPicker,
				minHeight: 0,
				maxHeight: geometry.size.height * 0.5
			) {
				if viewModel.isShowingEmojiPicker {
					HUD
				}
			}
		}
	}

	fileprivate var HUD: some View {
		LazyVGrid(columns: [GridItem(.adaptive(minimum: Metrics.Image.l.rawValue))]) {
			ForEach(Balloon.allCases.indices) { index in
				Button {
					viewModel.postViewAction(.pickedEmoji(Balloon.allCases[index]))
				} label: {
					Image(uiImage: Balloon.allCases[index].image ?? UIImage())
						.resizable()
						.aspectRatio(contentMode: .fit)
						.squareImage(.l)
				}
			}

			ForEach(Confetti.allCases.indices) { index in
				Button {
					viewModel.postViewAction(.pickedEmoji(Confetti.allCases[index]))
				} label: {
					Image(uiImage: Confetti.allCases[index].headshot ?? UIImage())
						.resizable()
						.aspectRatio(contentMode: .fit)
						.squareImage(.xl)
				}
			}
		}
		.padding()
	}
}

#if DEBUG
struct EmojiHUDPreview: PreviewProvider {
	static var previews: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: .constant(true),
				minHeight: 0,
				maxHeight: geometry.size.height * 0.5
			) {
				EmojiHUD().HUD
			}
		}.edgesIgnoringSafeArea(.bottom)
	}
}
#endif
