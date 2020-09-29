//
//  GameHUD.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine
import HiveEngine

struct GameHUD: View {
	@Environment(\.container) private var container
	@EnvironmentObject var viewModel: GameViewModel

	private let buttonSize: Metrics.Image = .xl
	private let buttonDistanceFromEdge: Metrics.Spacing = .xl

	private func stateIndicator(_ geometry: GeometryProxy) -> some View {
		Text(viewModel.displayState)
			.body()
			.foregroundColor(Color(.textRegular))
			.position(
				x: geometry.size.width / 2,
				y: geometry.size.height - (buttonSize + Metrics.Spacing.xl + Metrics.Spacing.m.rawValue)
			)
			.frame(alignment: .center)
	}

	private func settingsButton(_ geometry: GeometryProxy) -> some View {
		Button(action: {
			self.viewModel.postViewAction(.openSettings)
		}, label: {
			Image(uiImage: ImageAsset.Icon.info)
				.resizable()
				.renderingMode(.template)
				.foregroundColor(Color(.textSecondary))
				.squareImage(.l)
		})
		.position(
			x: geometry.size.width - (buttonSize.rawValue / 2 + buttonDistanceFromEdge.rawValue),
			y: buttonDistanceFromEdge.rawValue
		)
	}

	private func returnToGameButton(_ geometry: GeometryProxy) -> some View {
		HStack {
			Spacer()
			BasicButton<Never>("Return to board") {
				self.viewModel.postViewAction(.returnToGameBounds)
			}
			.opacity(viewModel.isOutOfBounds ? 1 : 0)
			.animation(.spring())
			Spacer()
		}
		.frame(width: geometry.size.width / 2)
		.position(
			x: geometry.size.width / 2,
			y: buttonDistanceFromEdge.rawValue + buttonSize.rawValue + Metrics.Spacing.m.rawValue
		)
	}

	private func emojiButton(_ geometry: GeometryProxy) -> some View {
		Button(action: {
			self.viewModel.postViewAction(.toggleEmojiPicker)
		}, label: {
			Image(uiImage: ImageAsset.Icon.smiley)
				.resizable()
				.renderingMode(.template)
				.foregroundColor(Color(.textSecondary))
				.squareImage(.l)
		})
		.position(
			x: buttonDistanceFromEdge.rawValue + buttonSize.rawValue / 2,
			y: buttonDistanceFromEdge.rawValue
		)
	}

	private func handButton(for player: Player, _ geometry: GeometryProxy) -> some View {
		let xOffset = (buttonDistanceFromEdge.rawValue + buttonSize.rawValue / 2) * (player == .white ? -1 : 1)
		let image = viewModel.handImage(for: player)

		return Button(action: {
			self.viewModel.postViewAction(.openHand(player))
		}, label: {
			HexImage(image, stroke: player.color)
				.placeholderTint(player.color)
				.squareInnerImage(.m)
		})
		.squareImage(buttonSize)
		.position(
			x: geometry.size.width / 2 + xOffset,
			y: geometry.size.height - (buttonDistanceFromEdge.rawValue + Metrics.Spacing.m.rawValue)
		)
	}

	var body: some View {
		GeometryReader { geometry in
			if !self.viewModel.shouldHideHUDControls {
				if self.container.has(feature: .emojiReactions) {
					self.emojiButton(geometry)
				}
				self.settingsButton(geometry)
				self.stateIndicator(geometry)
				self.handButton(for: .white, geometry)
				self.handButton(for: .black, geometry)
				self.returnToGameButton(geometry)
			}

			InformationHUD()
				.edgesIgnoringSafeArea(.bottom)
			ActionHUD()
				.edgesIgnoringSafeArea(.bottom)
			if self.container.has(feature: .emojiReactions) {
				EmojiHUD()
					.edgesIgnoringSafeArea(.bottom)
			}
		}
		.padding(.top, length: .l)
	}
}

// MARK: - Preview

#if DEBUG
struct GameHUDPreview: PreviewProvider {
	static var previews: some View {
		GameHUD()
			.environmentObject(GameViewModel(setup: .init(
				state: GameState(),
				mode: .play(player: .white, configuration: .online)
			)))
			.background(Color(.backgroundDark).edgesIgnoringSafeArea(.all))
	}
}
#endif
