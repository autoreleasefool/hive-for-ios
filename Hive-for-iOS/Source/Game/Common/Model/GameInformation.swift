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
	case pieceClass(Piece.Class)
	case stack([Piece])

	var stack: [Piece]? {
		guard case let .stack(stack) = self else { return nil }
		return stack
	}

	var title: String {
		switch self {
		case .piece(let piece): return piece.description
		case .pieceClass(let pieceClass): return pieceClass.description
		case .stack: return "Pieces in stack"
		}
	}

	var subtitle: String {
		switch self {
		case .piece(let piece): return piece.description
		case .pieceClass(let pieceClass): return pieceClass.description
		case .stack:
			return [
				"The following pieces have been stacked. A stack's color is identical to the piece on top.",
				"Only the top piece can be moved, and Mosquitoes can only copy the top piece.",
			].joined(separator: " ")
		}
	}
}
