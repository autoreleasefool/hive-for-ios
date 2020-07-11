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

	@State private var state: GameViewModel.State = .begin

	func stateIndicator(_ geometry: GeometryProxy) -> some View {
		Text(viewModel.displayState)
			.body()
			.foregroundColor(Color(.text))
			.position(
				x: geometry.size.width / 2,
				y: geometry.size.height - (buttonSize + Metrics.Spacing.xl + Metrics.Spacing.m.rawValue)
			)
			.frame(alignment: .center)
	}

	func settingsButton(_ geometry: GeometryProxy) -> some View {
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

	func emojiButton(_ geometry: GeometryProxy) -> some View {
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

	func handButton(for player: Player, _ geometry: GeometryProxy) -> some View {
		let xOffset = (buttonDistanceFromEdge.rawValue + buttonSize.rawValue / 2) * (player == .white ? -1 : 1)

		return Button(action: {
			self.viewModel.postViewAction(.presentInformation(.playerHand(.init(
				player: player,
				playingAs: self.viewModel.playingAs,
				state: self.viewModel.gameState
			))))
		}, label: {
			HexImage(ImageAsset.Icon.handFilled, stroke: player.color)
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
				self.emojiButton(geometry)
				self.settingsButton(geometry)
				self.stateIndicator(geometry)
				self.handButton(for: .white, geometry)
				self.handButton(for: .black, geometry)
			}

			InformationHUD()
				.edgesIgnoringSafeArea(.bottom)
			ActionHUD()
				.edgesIgnoringSafeArea(.bottom)
			if self.container.has(feature: .emojiReactions) {
				EmojiPicker(isOpen: self.$viewModel.showingEmojiPicker)
			}
		}
		.padding(.top, length: .l)
		.onReceive(viewModel.stateStore) { self.state = $0 }
	}
}

#if DEBUG
struct GameHUDPreview: PreviewProvider {
	static var previews: some View {
		GameHUD()
			.environmentObject(GameViewModel(initialState: GameState(), playingAs: .white, mode: .online))
			.background(Color(.backgroundDark).edgesIgnoringSafeArea(.all))
	}
}
#endif
