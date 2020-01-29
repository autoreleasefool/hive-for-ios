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
	let unitsInHand: [HiveEngine.Unit.Class: Int]

	init(player: Player, state: GameState) {
		self.player = player
		var unitsInHand: [HiveEngine.Unit.Class: Int] = [:]
		state.unitsInHand[player]?.forEach {
			unitsInHand[$0.class] = (unitsInHand[$0.class] ?? 0) + 1
		}

		self.unitsInHand = unitsInHand
	}
}
