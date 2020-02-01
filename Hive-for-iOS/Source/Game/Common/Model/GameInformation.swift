//
//  GameInformation.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveEngine

enum GameInformation {
	case piece(Piece)

	func description(in state: GameState) -> String {
		switch self {
		case .piece(let piece): return "\(piece.description) - \(state.position(of: piece))"
		}
	}
}
