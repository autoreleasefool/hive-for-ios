//
//  Experience+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-27.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import RealityKit
import HiveEngine

extension Experience.HiveGame {
	var allPieces: [Entity?] {
		return blackPieces + whitePieces
	}

	var blackPieces: [Entity?] {
		return [
			bA1,
			bA2,
			bA3,
			bB1,
			bB2,
			bG1,
			bG2,
			bG3,
			bL,
			bM,
			bP,
			bQ,
			bS1,
			bS2,
		]
	}

	var whitePieces: [Entity?] {
		return [
			wA1,
			wA2,
			wA3,
			wB1,
			wB2,
			wG1,
			wG2,
			wG3,
			wL,
			wM,
			wP,
			wQ,
			wS1,
			wS2,
		]
	}

	func pieces(for player: Player) -> [Entity?] {
		switch player {
		case .white: return whitePieces
		case .black: return blackPieces
		}
	}
}

extension Entity {
	func visit(using block: (Entity) -> Void) {
		block(self)

		for child in children {
			child.visit(using: block)
		}
	}

	var gamePiece: Piece? {
		return Piece(notation: self.name)
	}
}
