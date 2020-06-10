//
//  PlayerHand.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-28.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveEngine

struct PlayerHand {
	let player: Player
	let piecesInHand: [Piece.Class]

	init(player: Player, state: GameState) {
		self.player = player
		self.piecesInHand = Array(state.unitsInHand[player] ?? []).map { $0.class }.sorted()
	}
}
