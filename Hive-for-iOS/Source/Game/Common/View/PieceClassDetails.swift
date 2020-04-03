//
//  PieceClassDetails.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-27.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct PieceClassDetails: View {
	let pieceClass: Piece.Class
	let state: GameState

	private func pieceCount(count: Int) -> String {
		"\(count) \(count == 1 ? pieceClass.description : pieceClass.descriptionPlural)"
	}

	private func playerPieceStatus(for player: Player) -> String {
		let countInHand = state.unitsInHand[player]?.filter { $0.class == pieceClass }.count ?? 0
		let countInPlay = state.unitsInPlay[player]?.filter { $0.key.class == pieceClass }.count ?? 0
		let pieceCount: String
		if countInHand > 0 && countInPlay > 0 {
			pieceCount = "\(self.pieceCount(count: countInPlay)) on the board, " +
				"\(self.pieceCount(count: countInHand)) in their hand."
		} else if countInHand > 0 {
			pieceCount = "\(self.pieceCount(count: countInHand)) in their hand."
		} else if countInPlay > 0 {
			pieceCount = "\(self.pieceCount(count: countInPlay)) on the board."
		} else {
			pieceCount = "\(pieceClass.description) not in play."
		}
		return pieceCount
	}

	var body: some View {
		VStack(spacing: Metrics.Spacing.m.rawValue) {
			ForEach([Player.white, Player.black], id: \.description) { player in
				VStack(alignment: .leading, spacing: Metrics.Spacing.s.rawValue) {
					Text(player.description)
						.body()
						.foregroundColor(Color(player.color))
						.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
					Text(self.playerPieceStatus(for: player))
						.body()
						.foregroundColor(Color(.textSecondary))
						.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
				}
			}
		}
	}
}

#if DEBUG
struct PieceClassDetails_Previews: PreviewProvider {
	static var previews: some View {
		PieceClassDetails(pieceClass: .ant, state: GameState())
	}
}
#endif
