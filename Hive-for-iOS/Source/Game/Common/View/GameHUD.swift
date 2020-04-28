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
	@EnvironmentObject var viewModel: HiveGameViewModel

	private let buttonSize: Metrics.Image = .xl
	private let buttonDistanceFromEdge: Metrics.Spacing = .xl

	private func handleTransition(to newState: HiveGameViewModel.State) {
		switch newState {
		case .forfeit, .begin, .gameEnd, .gameStart, .opponentTurn, .playerTurn, .sendingMovement:
			#warning("TODO: handle remaining state changes in hud")
		}
	}

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
			HexImage(ImageAsset.Icon.info, stroke: .textSecondary)
				.placeholderTint(.textSecondary)
				.squareInnerImage(.s)
		})
		.squareImage(buttonSize)
		.position(
			x: geometry.size.width - (buttonSize.rawValue / 2 + buttonDistanceFromEdge.rawValue),
			y: buttonDistanceFromEdge.rawValue
		)
	}

	func handButton(for player: Player, _ geometry: GeometryProxy) -> some View {
		let xOffset = (buttonDistanceFromEdge.rawValue + buttonSize.rawValue / 2) * (player == .white ? -1 : 1)

		return Button(action: {
			self.viewModel.postViewAction(.presentPlayerHand(player))
		}, label: {
			HexImage(ImageAsset.Icon.hand, stroke: player.color)
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
				self.settingsButton(geometry)
				self.stateIndicator(geometry)
				self.handButton(for: .white, geometry)
				self.handButton(for: .black, geometry)
			}

			PlayerHandHUD()
				.edgesIgnoringSafeArea(.bottom)
			InformationHUD()
				.edgesIgnoringSafeArea(.bottom)
			ActionHUD()
				.edgesIgnoringSafeArea(.bottom)
		}
		.padding(.top, length: .l)
		.onReceive(viewModel.stateStore) { receivedValue in self.handleTransition(to: receivedValue) }
	}
}

#if DEBUG
struct GameHUDPreview: PreviewProvider {
	static var previews: some View {
		GameHUD()
			.environmentObject(HiveGameViewModel())
			.background(Color(.backgroundDark).edgesIgnoringSafeArea(.all))
	}
}
#endif
