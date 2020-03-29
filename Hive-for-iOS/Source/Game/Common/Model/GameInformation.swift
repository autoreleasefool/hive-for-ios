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
	case rule(HiveRule?)

	init?(fromLink link: String) {
		if link.starts(with: "class:"), let pieceClass = Piece.Class(fromName: String(link.substring(from: 6))) {
			self = .pieceClass(pieceClass)
		} else if link.starts(with: "rule:"), let rule = HiveRule(rawValue: String(link.substring(from: 5))) {
			self = .rule(rule)
		} else {
			return nil
		}
	}

	var stack: [Piece]? {
		guard case let .stack(stack) = self else { return nil }
		return stack
	}

	var title: String {
		switch self {
		case .piece(let piece): return GameInformation.pieceClass(piece.class).title
		case .pieceClass(let pieceClass): return pieceClass.description
		case .stack: return "Pieces in stack"
		case .rule(let rule): return rule?.title ?? "All rules"
		}
	}

	var subtitle: String? {
		switch self {
		case .piece(let piece): return GameInformation.pieceClass(piece.class).subtitle
		case .pieceClass(let pieceClass): return pieceClass.rules
		case .rule(let rule): return rule?.description
		case .stack: return
			"The following pieces have been [stacked](rule:stacks). A stack's color is identical to the piece " +
				"on top. Only the top piece can be moved, and [mosquitoes](class:Mosquito) can only copy the top piece."
		}
	}
}
