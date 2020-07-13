//
//  EmojiHUD.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-08.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct EmojiHUD: View {
	private static let size = CGSize(width: 80, height: 400)

	@EnvironmentObject private var viewModel: GameViewModel

	@GestureState private var pickerTransation: CGFloat = 0
	private var pickerOffset: CGFloat {
		viewModel.showingEmojiPicker ? Metrics.Spacing.m.rawValue : -(EmojiHUD.size.width + Metrics.Spacing.m.rawValue)
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
				ForEach(self.animatingEmoji, id: \.id) { emoji in
					AnimatedEmoji(emoji: emoji, isAnimating: self.isAnimating(emoji), geometry: geometry)
						.position(x: geometry.size.width / 2, y: geometry.size.height)
				}
			}
			.frame(width: geometry.size.width, height: geometry.size.height)
			.onReceive(self.viewModel.animatedEmoji) { self.animatingEmoji.append($0) }
		}
	}

	private func isAnimating(_ emoji: AnimateableEmoji) -> Binding<Bool> {
		Binding(
			get: { self.animatingEmoji.contains(emoji) },
			set: { newValue in
				guard !newValue, let index = self.animatingEmoji.firstIndex(of: emoji) else { return }
				self.animatingEmoji.remove(at: index)
			}
		)
	}

	// MARK: - Picker

	private var picker: some View {
		GeometryReader { geometry in
			VStack(alignment: .center, spacing: .m) {
				ForEach(Emoji.allCases.indices) { index in
					Button(action: {
						self.viewModel.postViewAction(.pickedEmoji(Emoji.allCases[index]))
					}, label: {
						Image(uiImage: Emoji.allCases[index].image ?? UIImage())
							.resizable()
							.aspectRatio(contentMode: .fit)
							.squareImage(.l)
							.clipShape(Circle())
					})
				}
			}
			.padding(.vertical, length: .m)
			.frame(width: EmojiHUD.size.width, height: EmojiHUD.size.height, alignment: .top)
			.background(Color(.actionSheetBackground))
			.cornerRadius(EmojiHUD.size.width / 2)
			.padding()
			.frame(width: geometry.size.width, alignment: .center)
			.animation(.interactiveSpring())
			.gesture(
				DragGesture().updating(self.$pickerTransation) { value, state, _ in
					state = value.translation.width
				}.onEnded { value in
					guard abs(value.translation.width) > EmojiHUD.size.width / 4 else { return }
					self.viewModel.showingEmojiPicker = value.translation.width > 0
				}
			)
			.offset(x: max(self.pickerOffset + self.pickerTransation, -EmojiHUD.size.width))
		}
		.offset(x: -EmojiHUD.size.width * 2 - Metrics.Spacing.m.rawValue / 2)
	}
}
