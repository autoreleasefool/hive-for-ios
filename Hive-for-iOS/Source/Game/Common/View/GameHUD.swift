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

	private func handleTransition(to newState: HiveGameViewModel.State) {
		switch newState {
		case .forfeit, .begin, .gameEnd, .gameStart, .opponentTurn, .playerTurn, .sendingMovement, .receivingMovement:
			#warning("TODO: handle remaining state changes in hud")
		}
	}

	var exitGameButton: some View {
		Button(action: {
			self.viewModel.postViewAction(.exitGame)
		}, label: {
			HexImage(ImageAsset.Icon.close, stroke: .backgroundLight)
				.placeholderTint(.backgroundLight)
				.squareInnerImage(.s)
		})
		.squareImage(.l)
		.position(x: Metrics.Image.l + Metrics.Spacing.m, y: Metrics.Image.l + Metrics.Spacing.m)
	}

	func handButton(for player: Player, geometry: GeometryProxy) -> some View {
		let xOffset = (Metrics.Image.xl + Metrics.Spacing.m) * (player == .white ? -1 : 1)

		return Button(action: {
			self.viewModel.handToShow = PlayerHand(player: player, state: self.viewModel.gameState)
		}, label: {
			HexImage(ImageAsset.Icon.hand, stroke: player.color)
				.placeholderTint(player.color)
				.squareInnerImage(.m)
		})
		.squareImage(.xl)
		.position(x: geometry.size.width / 2 + xOffset, y: geometry.size.height - (Metrics.Image.xl + Metrics.Spacing.m))
	}

	var body: some View {
		GeometryReader { geometry in
			if !self.viewModel.shouldHideHUDControls {
				self.exitGameButton
				self.handButton(for: .white, geometry: geometry)
				self.handButton(for: .black, geometry: geometry)
			}

			PlayerHandHUD()
			InformationHUD()
			ActionHUD()
		}
		.padding(.top, length: .l)
		.onReceive(viewModel.flowStateSubject) { receivedValue in self.handleTransition(to: receivedValue) }
	}
}

#if DEBUG
struct GameHUDPreview: PreviewProvider {
	static var previews: some View {
		GameHUD()
			.environmentObject(HiveGameViewModel())
			.background(Color(ColorAsset.backgroundDark))
	}
}
#endif
