//
//  RandomAgent.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2020-07-02.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveEngine

public class RandomAgent: AIAgent {
	public func playMove(in state: GameState) -> Movement {
		state.availableMoves.first ?? .pass
	}
}
