//
//  EmojiPicker.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-08.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct EmojiPicker: View {
	private static let size = CGSize(width: 80, height: 400)

	@EnvironmentObject private var viewModel: GameViewModel

	@Binding var isOpen: Bool

	init(isOpen: Binding<Bool>) {
		self._isOpen = isOpen
	}

	@GestureState private var translation: CGFloat = 0
	private var offset: CGFloat {
		isOpen ? Metrics.Spacing.m.rawValue : -(EmojiPicker.size.width + Metrics.Spacing.m.rawValue)
	}

	var body: some View {
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
			.frame(width: EmojiPicker.size.width, height: EmojiPicker.size.height, alignment: .top)
			.background(Color(.actionSheetBackground))
			.cornerRadius(EmojiPicker.size.width / 2)
			.padding()
			.frame(width: geometry.size.width, alignment: .center)
			.animation(.interactiveSpring())
			.gesture(
				DragGesture().updating(self.$translation) { value, state, _ in
					state = value.translation.width
				}.onEnded { value in
					guard abs(value.translation.width) > EmojiPicker.size.width / 4 else { return }
					self.isOpen = value.translation.width > 0
				}
			)
			.offset(x: max(self.offset + self.translation, -EmojiPicker.size.width))
		}
		.offset(x: -EmojiPicker.size.width * 2 - Metrics.Spacing.m.rawValue / 2)

//		GeometryReader { geometry in
//			HStack(spacing: 0) {
//				VStack(alignment: .center, spacing: .m) {
//					ForEach(Emoji.allCases.indices) { index in
//						Button(action: {
//							self.viewModel.postViewAction(.pickedEmoji(Emoji.allCases[index]))
//						}, label: {
//							Image(uiImage: Emoji.allCases[index].image ?? UIImage())
//								.resizable()
//								.scaledToFit()
//								.squareImage(.l)
//						})
//					}
//				}
//				.frame(width: EmojiPicker.size.width, height: EmojiPicker.size.height, alignment: .top)
//				.background(Color(.actionSheetBackground))
//				.cornerRadius(EmojiPicker.size.width / 2)
//				Circle()
//					.fill(Color.white)
//					.frame(width: EmojiPicker.handleSize, height: EmojiPicker.handleSize)
//			}
//			.frame(width: geometry.size.width + EmojiPicker.size.width, height: geometry.size.height, alignment: .leading)
//			.animation(.interactiveSpring())
//			.gesture(
//				DragGesture().updating(self.$translation) { value, state, _ in
//					state = value.translation.width
//				}.onEnded { value in
//					guard abs(value.translation.width) > EmojiPicker.size.width / 4 else { return }
//					self.isOpen = value.translation.width > 0
//				}
//			)
//			.offset(x: max(self.offset + self.translation, -EmojiPicker.size.width))
//		}
	}
}
