//
//  PlayerHandView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct PlayerHandView: View {
	@EnvironmentObject private var viewModel: GameViewModel

	let hand: GameInformation.PlayerHand
	@State private var didLongPress = false

	var body: some View {
		let totalSpaceForRow = UIScreen.main.bounds.width - Metrics.Spacing.m.rawValue
		let tilesPerRow = Int(totalSpaceForRow / (Metrics.Image.l.rawValue + Metrics.Spacing.m.rawValue))
		let rows = hand.piecesInHand.chunked(into: tilesPerRow)

		return VStack(alignment: .leading, spacing: .m) {
			ForEach(rows.indices) {
				self.pieceRow(pieces: rows[$0])
			}
		}
	}

	private func pieceRow(pieces: [Piece.Class]) -> some View {
		HStack(spacing: .m) {
			ForEach(pieces.indices) { index in
				self.piece(pieceClass: pieces[index])
			}
			Spacer()
		}
	}

	private func piece(pieceClass: Piece.Class) -> some View {
		Button(action: {
			self.viewModel.postViewAction(.closeInformation(withFeedback: false))
			if self.didLongPress {
				self.didLongPress = false
				self.viewModel.postViewAction(.enquiredFromHand(pieceClass))
			} else {
				self.viewModel.postViewAction(.selectedFromHand(self.hand.player, pieceClass))
			}
		}, label: {
			Image(uiImage: pieceClass.image)
				.renderingMode(.template)
				.resizable()
				.scaledToFit()
				.squareImage(.l)
				.foregroundColor(Color(hand.player.color))
		})
	}
}
