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

	@EnvironmentObject private var viewModel: GameViewModel
	@State private var didLongPress = false

	private func title(hand: PlayerHand, playingAs: Player) -> Text {
		Text(
			hand.player == playingAs
				? "Your hand (\(hand.player.description.lowercased()))"
				: "Opponent's hand (\(hand.player.description.lowercased()))"
		)
	}

	private func informationButton(onTap: @escaping () -> Void) -> some View {
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

	private func tileRow(pieces: [Piece.Class], owner: Player, playingAs: Player) -> some View {
		HStack(spacing: .m) {
			ForEach(pieces.indices) { index in
				self.tile(pieceClass: pieces[index], owner: owner, playingAs: playingAs)
			}
			Spacer()
		}
	}

	private func tile(pieceClass: Piece.Class, owner: Player, playingAs: Player) -> some View {
		Button(action: {
			self.viewModel.presentingPlayerHand.wrappedValue = false
			if self.didLongPress {
				self.didLongPress = false
				self.viewModel.postViewAction(.enquiredFromHand(pieceClass))
			} else {
				self.viewModel.postViewAction(.selectedFromHand(owner, pieceClass))
			}
		}, label: {
			Image(uiImage: pieceClass.image)
				.renderingMode(.template)
				.resizable()
				.scaledToFit()
				.squareImage(.l)
				.foregroundColor(Color(owner.color))
		})
		.simultaneousGesture(
			LongPressGesture().onEnded { _ in self.didLongPress = true }
		)
	}

	fileprivate func HUD(hand: PlayerHand, playingAs: Player) -> some View {
		let totalSpaceForRow = UIScreen.main.bounds.width - Metrics.Spacing.m.rawValue
		let tilesPerRow = Int(totalSpaceForRow / (Metrics.Image.l.rawValue + Metrics.Spacing.m.rawValue))
		let rows = hand.piecesInHand.chunked(into: tilesPerRow)

		return VStack(alignment: .leading, spacing: .m) {
			self.title(hand: hand, playingAs: playingAs)
				.subtitle()
				.foregroundColor(Color(.text))
			ForEach(rows.indices) {
				self.tileRow(pieces: rows[$0], owner: hand.player, playingAs: playingAs)
			}
		}
		.padding(.horizontal, length: .m)
	}

	var body: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: self.viewModel.presentingPlayerHand,
				minHeight: 0,
				maxHeight: geometry.size.height / 2
			) {
				if self.viewModel.presentingPlayerHand.wrappedValue {
					self.HUD(hand: self.viewModel.presentedPlayerHand!, playingAs: self.viewModel.playingAs)
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
		.background(Color(.backgroundDark).edgesIgnoringSafeArea(.all))
		.edgesIgnoringSafeArea(.bottom)
	}
}
#endif
