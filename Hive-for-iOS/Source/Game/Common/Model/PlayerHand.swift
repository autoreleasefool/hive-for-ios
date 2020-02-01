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
	let piecesInHand: [Piece.Class: Int]

	init(player: Player, state: GameState) {
		self.player = player
		var piecesInHand: [Piece.Class: Int] = [:]
		state.unitsInHand[player]?.forEach {
			piecesInHand[$0.class] = (piecesInHand[$0.class] ?? 0) + 1
		}

		self.piecesInHand = piecesInHand
	}
}
