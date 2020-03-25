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

	fileprivate func HUD(hand: PlayerHand) -> some View {
		GeometryReader { geometry in
			VStack(alignment: .leading) {
				Text("\(hand.player.description) hand")
					.underline()
					.subtitle()
					.foregroundColor(Color(.text))
					.padding(.horizontal, length: .m)
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach(hand.piecesInHand.keys.sorted()) { pieceClass in
							self.card(
								pieceClass: pieceClass,
								count: hand.piecesInHand[pieceClass]!,
								viewPortWidth: geometry.size.width
							)
						}
					}
					.padding(.horizontal, length: .m)
				}
			}
		}
	}

	var body: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: self.viewModel.showPlayerHand,
				minHeight: 0,
				maxHeight: geometry.size.height / 3.0
			) {
				if self.viewModel.showPlayerHand.wrappedValue {
					self.HUD(hand: self.viewModel.handToShow!)
				} else {
					EmptyView()
				}
			}
		}
	}
}

#if DEBUG
struct PlayerHandHUDPreview: PreviewProvider {
	@State static var isOpen: Bool = true

	static var previews: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: $isOpen,
				minHeight: 0,
				maxHeight: geometry.size.height / 3.0
			) {
				PlayerHandHUD().HUD(hand: PlayerHand(player: .white, state: GameState()))
			}
		}.edgesIgnoringSafeArea(.all)
	}
}
#endif
