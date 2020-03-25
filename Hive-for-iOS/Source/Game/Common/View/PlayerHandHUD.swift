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
	private static let cardWidth: CGFloat = 240
	private static let cardHeight: CGFloat = 150

	@EnvironmentObject var viewModel: HiveGameViewModel

	func title(hand: PlayerHand, playingAs: Player) -> Text {
		Text(
			hand.player == playingAs
				? "Your hand (\(hand.player.description.lowercased()))"
				: "Opponent's hand (\(hand.player.description.lowercased()))"
		)
	}

	func informationButton(onTap: @escaping () -> Void) -> some View {
		Button(
			action: onTap,
			label: {
				Image(uiImage: ImageAsset.Icon.info)
					.renderingMode(.template)
					.resizable()
					.scaledToFit()
					.squareImage(.s)
					.foregroundColor(Color(.text))
					.padding(.all, length: .m)
			}
		)
	}

	private func card(pieceClass: Piece.Class, count: Int, owner: Player, playingAs: Player) -> some View {
		ZStack {
			Button(
				action: {
					if owner == playingAs {
						self.viewModel.postViewAction(.selectedFromHand(pieceClass))
					} else {
						self.viewModel.postViewAction(.enquiredFromHand(pieceClass))
					}
				},
				label: {
					VStack(spacing: 0) {
						Spacer()

						HStack(spacing: 0) {
							Image(uiImage: pieceClass.image)
								.renderingMode(.template)
								.resizable()
								.scaledToFit()
								.squareImage(.l)
								.foregroundColor(Color(owner == .white ? .white : .primary))
							VStack {
								Text(pieceClass.description)
									.subtitle()
									.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
									.foregroundColor(Color(.text))
								Text("\(count) remaining")
									.body()
									.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
									.padding(.top, length: .s)
									.foregroundColor(Color(.textSecondary))
							}
								.padding(.leading, length: .m)
						}
							.padding(.horizontal, length: .m)

						Spacer()

						Text(owner == playingAs ? "Place" : "Learn more")
							.body()
							.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
							.foregroundColor(Color(.textSecondary))
							.padding(.bottom, length: .s)
					}
						.frame(width: PlayerHandHUD.cardWidth, height: PlayerHandHUD.cardHeight)
						.background(
							RoundedRectangle(cornerRadius: Metrics.Spacing.s.rawValue)
								.fill(Color(.backgroundLight))
								.shadow(radius: Metrics.Spacing.s.rawValue)
						)
						.padding(.leading, length: .m)
				}
			)

			Group {
				VStack(alignment: .trailing, spacing: 0) {
					HStack(alignment: .top, spacing: 0) {
						Spacer()
						informationButton {
							self.viewModel.postViewAction(.enquiredFromHand(pieceClass))
						}
					}
					Spacer()
				}
			}
				.frame(width: PlayerHandHUD.cardWidth, height: PlayerHandHUD.cardHeight)
				.padding(.leading, length: .m)
		}
	}

	fileprivate func HUD(hand: PlayerHand, playingAs: Player) -> some View {
		VStack(alignment: .leading) {
			self.title(hand: hand, playingAs: playingAs)
				.subtitle()
				.foregroundColor(Color(.text))
				.padding(.horizontal, length: .m)
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 0) {
					ForEach(hand.piecesInHand.keys.sorted()) { pieceClass in
						self.card(
							pieceClass: pieceClass,
							count: hand.piecesInHand[pieceClass]!,
							owner: hand.player,
							playingAs: playingAs
						)
					}
				}
					.padding(.trailing, length: .m)
			}
		}
	}

	var body: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: self.viewModel.showPlayerHand,
				minHeight: 0,
				maxHeight: geometry.size.height / 3.0,
				backgroundColor: .clear
			) {
				if self.viewModel.showPlayerHand.wrappedValue {
					self.HUD(hand: self.viewModel.handToShow!, playingAs: self.viewModel.playingAs)
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
				maxHeight: geometry.size.height / 3.0,
				backgroundColor: .clear
			) {
				PlayerHandHUD().HUD(hand: PlayerHand(player: .black, state: GameState()), playingAs: .white)
			}
		}
			.background(Color(.backgroundDark))
			.edgesIgnoringSafeArea(.all)

	}
}
#endif
