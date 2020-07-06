//
//  GameInformation.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct EndState {
	let winner: Player?
	let playingAs: Player

	var playerIsWinner: Bool {
		playingAs == winner
	}

	var isTied: Bool {
		winner == nil
	}
}

enum GameInformation {
	case piece(Piece)
	case pieceClass(Piece.Class)
	case stack([Piece])
	case rule(GameRule?)
	case gameEnd(EndState)
	case settings
	case reconnecting(Int)

	init?(fromLink link: String) {
		if link.starts(with: "class:"), let pieceClass = Piece.Class(fromName: String(link.substring(from: 6))) {
			self = .pieceClass(pieceClass)
		} else if link.starts(with: "rule:"), let rule = GameRule(rawValue: String(link.substring(from: 5))) {
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
		case .gameEnd(let state):
			if let player = state.winner {
				return "\(player) wins!"
			} else {
				return "It's a tie!"
			}
		case .settings: return "Settings"
		case .reconnecting: return "Disconnected from server"
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
		case .gameEnd(let state):
			if state.isTied {
				return "Both queens have been surrounded in the same turn, which means it's a tie! " +
					"Return to the lobby to play another game."
			} else {
				return "\(state.playerIsWinner ? "You have" : "Your opponent has") surrounded " +
					"\(state.playerIsWinner ? "your opponent's" : "your") queen and won the game! " +
					"Return to the lobby to play another game."
			}
		case .settings: return nil
		case .reconnecting(let attempts):
			return "The connection to the server has been lost. The game will automatically attempt to reconnect, " +
				"but if a connection cannot be made, you will forfeit the match. This dialog will dismiss " +
				"automatically if the connection is restored.\n" +
				"Please wait (\(attempts)/\(OnlineGameClient.maxReconnectAttempts))."
		}
	}

	var dismissable: Bool {
		switch self {
		case .reconnecting: return false
		case .gameEnd, .piece, .pieceClass, .rule, .stack, .settings: return true
		}
	}
}
