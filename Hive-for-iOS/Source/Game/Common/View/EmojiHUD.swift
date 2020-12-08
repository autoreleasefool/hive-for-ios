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

	@State private var animatingBalloons: [AnimateableBalloon] = []

	var body: some View {
		ZStack {
			animatedBalloons
			picker
		}
	}

	// MARK: Animations

	private var animatedBalloons: some View {
		GeometryReader { geometry in
			ZStack {
				ForEach(animatingBalloons, id: \.id) { emoji in
					AnimatedBalloon(emoji: emoji, isAnimating: isAnimating(emoji), geometry: geometry)
						.position(x: geometry.size.width / 2, y: geometry.size.height)
				}
			}
			.frame(width: geometry.size.width, height: geometry.size.height)
			.onReceive(viewModel.animatedEmoji) { emoji in
				guard let balloon = emoji as? Balloon else { return }
				let animations = (0...Int.random(in: (15...20)))
					.map { _ in AnimateableBalloon(emoji: balloon, geometry: geometry) }
				animatingBalloons.append(contentsOf: animations)
			}
		}
	}

	private func isAnimating(_ emoji: AnimateableBalloon) -> Binding<Bool> {
		Binding(
			get: { animatingBalloons.contains(emoji) },
			set: { newValue in
				guard !newValue, let index = animatingBalloons.firstIndex(of: emoji) else { return }
				animatingBalloons.remove(at: index)
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
						.clipShape(Circle())
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
