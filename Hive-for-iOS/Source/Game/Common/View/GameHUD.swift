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

	private var hasEmojiEnabled: Bool {
		container.has(feature: .emojiMasterMode) || (
			container.has(feature: .emojiReactions) &&
			container.preferences.isEmotesEnabled &&
			!(container.account?.isOffline == true)
		)
	}

	private func stateIndicator(_ geometry: GeometryProxy) -> some View {
		Text(viewModel.displayState)
			.font(.body)
			.foregroundColor(Color(.textRegular))
			.position(
				x: geometry.size.width / 2,
				y: geometry.size.height - (buttonSize + Metrics.Spacing.xl + Metrics.Spacing.m.rawValue)
			)
			.frame(alignment: .center)
	}

	private func settingsButton(_ geometry: GeometryProxy) -> some View {
		Button {
			viewModel.postViewAction(.openGameSettings)
		} label: {
			Image(uiImage: ImageAsset.Icon.info)
				.resizable()
				.renderingMode(.template)
				.foregroundColor(Color(.textSecondary))
				.squareImage(.l)
		}
		.position(
			x: geometry.size.width - (buttonSize.rawValue / 2 + buttonDistanceFromEdge.rawValue),
			y: buttonDistanceFromEdge.rawValue
		)
	}

	private func returnToGameButton(_ geometry: GeometryProxy) -> some View {
		HStack {
			Spacer()
			PrimaryButton("Return to board") {
				viewModel.postViewAction(.returnToGameBounds)
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
		Button {
			viewModel.postViewAction(.toggleEmojiPicker)
		} label: {
			Image(uiImage: ImageAsset.Icon.smiley)
				.resizable()
				.renderingMode(.template)
				.foregroundColor(Color(.textSecondary))
				.squareImage(.l)
		}
		.position(
			x: buttonDistanceFromEdge.rawValue + buttonSize.rawValue / 2,
			y: buttonDistanceFromEdge.rawValue
		)
	}

	private func handButton(for player: Player, _ geometry: GeometryProxy) -> some View {
		let xOffset = (buttonDistanceFromEdge.rawValue + buttonSize.rawValue / 2) * (player == .white ? -1 : 1)
		let image = viewModel.handImage(for: player)

		return Button {
			viewModel.postViewAction(.openHand(player))
		} label: {
			HexImage(image, stroke: player.color)
				.placeholderTint(player.color)
				.squareInnerImage(.m)
		}
		.squareImage(buttonSize)
		.position(
			x: geometry.size.width / 2 + xOffset,
			y: geometry.size.height - (buttonDistanceFromEdge.rawValue + Metrics.Spacing.m.rawValue)
		)
	}

	private func replayButton(_ geometry: GeometryProxy) -> some View {
		Group {
//			if !container.preferences.hasDismissedReplayTooltip {
//				Tooltip("If you forget your opponent's last move, tap here for a reminder!") {
//					viewModel.postViewAction(.dismissReplayTooltip)
//				}
//					.originating(
//						from: CGPoint(
//							x: geometry.size.width - (buttonDistanceFromEdge.rawValue + Metrics.Spacing.m.rawValue),
//							y: geometry.size.height
//								- (buttonDistanceFromEdge.rawValue + Metrics.Spacing.m.rawValue)
//								- buttonSize.rawValue
//						)
//					)
//			}

			Button {
				viewModel.postViewAction(.replayLastMove)
			} label: {
				Image(systemName: "arrow.2.circlepath")
					.imageScale(.medium)
					.foregroundColor(Color(.textSecondary))
			}
			.position(
				x: geometry.size.width - (buttonDistanceFromEdge.rawValue + Metrics.Spacing.m.rawValue),
				y: geometry.size.height - (buttonDistanceFromEdge.rawValue + Metrics.Spacing.m.rawValue)
			)
		}
	}

	var body: some View {
		GeometryReader { geometry in
			if !viewModel.shouldHideHUDControls {
				if hasEmojiEnabled {
					emojiButton(geometry)
				}
				settingsButton(geometry)
				stateIndicator(geometry)
				handButton(for: .white, geometry)
				handButton(for: .black, geometry)
				returnToGameButton(geometry)

				if viewModel.gameState.updates.count > 0 {
					replayButton(geometry)
				}
			}

			if hasEmojiEnabled {
				EmojiHUD()
					.edgesIgnoringSafeArea(.bottom)
			}
			InformationHUD()
				.edgesIgnoringSafeArea(.bottom)
			ActionHUD()
				.edgesIgnoringSafeArea(.bottom)
		}
		.padding(.top)
	}
}

// MARK: - Preview

#if DEBUG
struct GameHUDPreview: PreviewProvider {
	static var previews: some View {
		GameHUD()
			.environmentObject(GameViewModel(setup: Game.Setup(
				match: Match.createOfflineMatch(
					against: .agent(.random),
					withOptions: Set(),
					withGameOptions: Set()
				),
				state: GameState(),
				mode: .singlePlayer(player: .white, configuration: .local)
			)))
			.background(Color(.backgroundDark).edgesIgnoringSafeArea(.all))
	}
}
#endif
