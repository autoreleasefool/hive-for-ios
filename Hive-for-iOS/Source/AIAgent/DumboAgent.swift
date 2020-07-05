//
//  DumboAgent.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-02.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveEngine

class DumboAgent: AIAgent {
	func playMove(in state: GameState) -> Movement {
		state.availableMoves.first ?? .pass
	}
}
