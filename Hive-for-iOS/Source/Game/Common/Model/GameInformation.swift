//
//  GameInformation.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

enum GameInformation {
	case piece(Piece)
	case pieceClass(Piece.Class)
	case stack([Piece])
	case rule(HiveRule)

	var stack: [Piece]? {
		guard case let .stack(stack) = self else { return nil }
		return stack
	}

	var title: String {
		switch self {
		case .piece(let piece): return GameInformation.pieceClass(piece.class).title
		case .pieceClass(let pieceClass): return pieceClass.description
		case .stack: return "Pieces in stack"
		case .rule(let rule): return rule.title
		}
	}

	var subtitle: [FormattedText] {
		switch self {
		case .piece(let piece): return GameInformation.pieceClass(piece.class).subtitle
		case .pieceClass(let pieceClass): return pieceClass.rules
		case .rule(let rule): return rule.description
		case .stack:
			return [
				.plain("The following pieces have been stacked. A stack's color is identical to the piece on top. "),
				.plain("Only the top piece can be moved, and "),
				.link("mosquitoes", .pieceClass(.mosquito)),
				.plain(" can only copy the top piece."),
			]
		}
	}
}
