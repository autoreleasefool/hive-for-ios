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
	case playerHand(PlayerHand)
	case piece(Piece)
	case pieceClass(Piece.Class)
	case stack([Piece])
	case rule(GameRule?)
	case gameEnd(EndState)
	case settings
	case playerMustPass
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
		case .playerHand(let hand): return (hand.isPlayerHand ? "Your" : "Opponent's") + " hand"
		case .piece(let piece): return piece.class.description
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
		case .playerMustPass: return "No moves available"
		case .reconnecting: return "Disconnected from server"
		}
	}

	var subtitle: String? {
		switch self {
		case .playerHand(let hand): return hand.player.description
		case .piece(let piece): return piece.class.rules
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
		case .reconnecting(let attempts):
			return "The connection to the server has been lost. The game will automatically attempt to reconnect, " +
				"but if a connection cannot be made, you will forfeit the match. This dialog will dismiss " +
				"automatically if the connection is restored.\n" +
				"Please wait (\(attempts)/\(OnlineGameClient.maxReconnectAttempts))."
		case .playerMustPass:
			return "Abiding by the rules of the game, there is nowhere for you to place a new piece, " +
				"or move an existing piece on the board. You are considered blocked and must [pass](rule:Passing) this turn. " +
				"Your opponent will move again. Dismiss this dialog or tap below to pass your turn."
		case .settings: return nil
		}
	}

	var prefersMarkdown: Bool {
		switch self {
		case .playerHand, .settings: return false
		case .piece, .pieceClass, .rule, .stack, .gameEnd, .reconnecting, .playerMustPass: return true
		}
	}

	var dismissable: Bool {
		switch self {
		case .reconnecting: return false
		case .gameEnd, .piece, .pieceClass, .playerHand, .rule, .stack, .settings, .playerMustPass: return true
		}
	}

	var hasCloseButton: Bool {
		switch self {
		case .gameEnd, .playerMustPass: return false
		case .piece, .pieceClass, .playerHand, .rule, .stack, .settings, .reconnecting: return true
		}
	}
}

// MARK: EndState

extension GameInformation {
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
}

// MARK: PlayerHand

extension GameInformation {
	struct PlayerHand {
		let player: Player
		let playingAs: Player
		let piecesInHand: [Piece.Class]

		var isPlayerHand: Bool {
			playingAs == player
		}

		init(player: Player, playingAs: Player, state: GameState) {
			self.player = player
			self.playingAs = playingAs
			self.piecesInHand = Array(state.unitsInHand[player] ?? []).map { $0.class }.sorted()
		}
	}
}
