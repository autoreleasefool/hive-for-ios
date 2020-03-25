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

	private func card(pieceClass: Piece.Class, count: Int, viewPortWidth: CGFloat) -> some View {
		GeometryReader { geometry in
			ZStack {
				RoundedRectangle(cornerRadius: Metrics.Spacing.s.rawValue)
					.fill(Color(.backgroundLight))
					.shadow(radius: Metrics.Spacing.s.rawValue)

				Button(
					action: { self.viewModel.postViewAction(.enquiredFromHand(pieceClass)) },
					label: {
						Image(systemName: "info.circle")
							.resizable()
							.foregroundColor(Color(.text))
							.squareImage(.s)
							.padding()
							.position(
								x: geometry.size.width - (Metrics.Spacing.s + Metrics.Spacing.s).rawValue,
								y: Metrics.Spacing.m.rawValue
							)
					}
				)

				Button(
					action: { self.viewModel.postViewAction(.selectedFromHand(pieceClass)) },
					label: {
						ZStack {
							Text(pieceClass.notation)
								.foregroundColor(Color(.text))
								.subtitle()
							Hex()
								.stroke(Color(.text), lineWidth: CGFloat(2))
								.squareImage(.l)
						}
						.padding()
					}
				)
			}
		}
		.frame(width: viewPortWidth * 0.75)
	}

	var body: some View {
		GeometryReader { geometry in
			VStack(alignment: .leading) {
				Text("\(self.hand.player.description) hand")
					.underline()
					.subtitle()
					.foregroundColor(Color(.text))
					.padding(.horizontal, length: .m)
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach(self.hand.piecesInHand.keys.sorted()) { pieceClass in
							self.card(
								pieceClass: pieceClass,
								count: self.hand.piecesInHand[pieceClass]!,
								viewPortWidth: geometry.size.width
							)
						}
					}
					.padding(.horizontal, length: .m)
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
