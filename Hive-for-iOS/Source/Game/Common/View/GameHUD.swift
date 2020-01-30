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

	var exitGameButton: some View {
		Button(action: {
			self.viewModel.postViewAction(.exitGame)
		}, label: {
			HexImage(ImageAsset.Icon.close, stroke: .background)
				.placeholderTint(.background)
				.squareInnerImage(.s)
		})
		.squareImage(.l)
		.position(x: Metrics.Image.l + Metrics.Spacing.m, y: Metrics.Image.l + Metrics.Spacing.m)
	}

	func handButton(for player: Player, geometry: GeometryProxy) -> some View {
		let color: ColorAsset = player == .white ? .text : .background
		let xOffset = (Metrics.Image.xl + Metrics.Spacing.m) * (player == .white ? -1 : 1)

		return Button(action: {
			self.viewModel.handToShow = PlayerHand(player: player, state: self.viewModel.gameState)
		}, label: {
			HexImage(ImageAsset.Icon.hand, stroke: color)
				.placeholderTint(color)
				.squareInnerImage(.m)
		})
		.squareImage(.xl)
		.position(x: geometry.size.width / 2 + xOffset, y: geometry.size.height - (Metrics.Image.xl + Metrics.Spacing.m))
	}

	var body: some View {
		GeometryReader { geometry in
			self.exitGameButton
			self.handButton(for: .white, geometry: geometry)
			self.handButton(for: .black, geometry: geometry)

			BottomSheet(
				isOpen: self.viewModel.showPlayerHand,
				minHeight: 0,
				maxHeight: geometry.size.height * 0.3,
				backgroundColor: .clear
			) {
				if self.viewModel.showPlayerHand.wrappedValue {
					PlayerHandHUD(hand: self.viewModel.handToShow!)
				} else {
					EmptyView()
				}
			}

			BottomSheet(
				isOpen: self.viewModel.hasInformation,
				minHeight: 0,
				maxHeight: geometry.size.height * 0.5
			) {
				if self.viewModel.hasInformation.wrappedValue {
					InformationHUD(information: self.viewModel.informationToPresent!, state: self.viewModel.gameState)
				} else {
					EmptyView()
				}
			}
		}
		.padding(.top, .l)
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
