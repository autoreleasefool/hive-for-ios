//
//  GameHUD.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine

struct GameHUD: View {
	@EnvironmentObject var viewModel: HiveGameViewModel

	var body: some View {
		GeometryReader { geometry in
			Button(action: {
				self.viewModel.postViewAction(.exitGame)
			}, label: {
				HexImage(ImageAsset.Icon.close, stroke: .background)
					.placeholderTint(.background)
					.squareInnerImage(.s)
			})
			.squareImage(.l)
			.position(x: Metrics.Image.l + Metrics.Spacing.m, y: Metrics.Image.l + Metrics.Spacing.m)

			Button(action: {
				self.viewModel.handToShow = PlayerHand(player: .white, state: self.viewModel.gameState)
			}, label: {
				HexImage(ImageAsset.Icon.hand, stroke: .text)
					.placeholderTint(.text)
					.squareInnerImage(.m)
			})
			.squareImage(.xl)
			.position(x: geometry.size.width / 2 - (Metrics.Image.xl + Metrics.Spacing.m), y: geometry.size.height - (Metrics.Image.xl + Metrics.Spacing.m))

			Button(action: {
				self.viewModel.handToShow = PlayerHand(player: .black, state: self.viewModel.gameState)
			}, label: {
				HexImage(ImageAsset.Icon.hand, stroke: .background)
					.placeholderTint(.background)
					.squareInnerImage(.m)
			})
			.squareImage(.xl)
			.position(x: geometry.size.width / 2 + (Metrics.Image.xl + Metrics.Spacing.m), y: geometry.size.height - (Metrics.Image.xl + Metrics.Spacing.m))

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
