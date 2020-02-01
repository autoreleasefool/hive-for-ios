//
//  PlayerHandHUD.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-28.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct PlayerHandHUD: View {
	@EnvironmentObject var viewModel: HiveGameViewModel
	let hand: PlayerHand

	private func card(pieceClass: Piece.Class, count: Int) -> some View {
		Button(
			action: { self.viewModel.postViewAction(.selectedFromHand(pieceClass)) },
			label: {
				ZStack {
					RoundedRectangle(cornerRadius: Metrics.Spacing.s.rawValue)
						.fill(Color(ColorAsset.background))
						.shadow(radius: Metrics.Spacing.s.rawValue)
					HStack {
						ZStack {
							Text(pieceClass.notation)
								.foregroundColor(Color(ColorAsset.text))
								.subtitle()
							Hex()
								.stroke(Color(ColorAsset.text), lineWidth: CGFloat(2))
								.squareImage(.l)
						}
						VStack {
							Text(pieceClass.description)
								.foregroundColor(Color(ColorAsset.text))
								.title()
							Text(count > 0 ? "\(count) remaining" : "All in play")
								.foregroundColor(Color(ColorAsset.textSecondary))
								.body()
						}
					}
				}
				.frame(width: 300)
			}
		)
	}

	var body: some View {
		VStack {
			Text("\(hand.player.description) hand")
			ScrollView(.horizontal, showsIndicators: false) {
				HStack {
					ForEach(hand.piecesInHand.keys.sorted()) { pieceClass in
						self.card(pieceClass: pieceClass, count: self.hand.piecesInHand[pieceClass]!)
					}
				}
			}
		}
	}
}

#if DEBUG
struct PlayerHandHUDPreview: PreviewProvider {
	static var previews: some View {
		EmptyView()
	}
}
#endif
