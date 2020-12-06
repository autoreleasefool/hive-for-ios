//
//  LocalGameClient.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation
import HiveEngine

class LocalGameClient: GameClient {
	private var state: LocalGameState?

	private(set) var subject: PassthroughSubject<GameClientEvent, GameClientError>?

	var isPrepared: Bool {
		state != nil
	}

	func prepare(configuration: GameClientConfiguration) {
		switch configuration {
		case .local(let gameState, let whitePlayer, let blackPlayer):
			prepareLocalConfiguration(gameState, whitePlayer, blackPlayer)
		case .agent(let gameState, let player, let agentConfiguration):
			prepareAgentConfiguration(gameState, player, agentConfiguration)
		case .online:
			break
		}
	}

	private func prepareAgentConfiguration(
		_ gameState: GameState,
		_ player: Player,
		_ agentConfiguration: AgentConfiguration
	) {
		self.state = AgentGameState(
			gameState: GameState(from: gameState),
			localPlayer: player,
			agentConfiguration: agentConfiguration,
			agentPlayer: agentConfiguration.agent()
		)
	}

	private func prepareLocalConfiguration(
		_ gameState: GameState,
		_ whitePlayer: UUID,
		_ blackPlayer: UUID
	) {
		self.state = PlayerGameState(
			gameState: GameState(from: gameState),
			whitePlayer: whitePlayer,
			blackPlayer: blackPlayer
		)
	}

	func openConnection() -> AnyPublisher<GameClientEvent, GameClientError> {
		guard isPrepared else {
			return Fail(error: .notPrepared).eraseToAnyPublisher()
		}

		if let subject = subject {
			subject.send(.alreadyConnected)
			return subject.eraseToAnyPublisher()
		}

		return createPublisher()
	}

	func reconnect() -> AnyPublisher<GameClientEvent, GameClientError> {
		guard isPrepared else {
			return Fail(error: .notPrepared).eraseToAnyPublisher()
		}

		if let subject = subject {
			subject.send(.alreadyConnected)
			return subject.eraseToAnyPublisher()
		}

		return createPublisher()
	}

	private func createPublisher() -> AnyPublisher<GameClientEvent, GameClientError> {
		defer {
			// Send a `connected` message after the publisher has been returned
			DispatchQueue.main.async { [weak self] in
				self?.subject?.send(.connected)
			}
		}

		let publisher = PassthroughSubject<GameClientEvent, GameClientError>()
		self.subject = publisher
		return publisher.eraseToAnyPublisher()
	}

	func close() {
		subject?.send(completion: .finished)
		resetState()
	}

	func send(_ message: GameClientMessage, completionHandler: ((Error?) -> Void)?) {
		switch message {
		case .forfeit:
			playerForfeit()
		case .movement(let movement):
			playerMovement(movement)
		case .readyToPlay:
			playFirstMove()
		case .message, .setOption:
			// Ignored for offline play
			break
		}
		completionHandler?(nil)
	}

	private func resetState() {
		state = nil
		subject = nil
	}
}

// MARK: - Player actions

private extension LocalGameClient {
	func playerForfeit() {
		guard let state = state else { return }
		subject?.send(.message(.forfeit(state.forfeit())))
	}

	func playerMovement(_ movement: RelativeMovement) {
		guard let state = state else {
			subject?.send(.message(.error(GameServerError(
				code: .invalidCommand,
				description: "There doesn't appear to be a game in progress."
			))))
			return
		}

		guard state.isPlayerTurn else {
			subject?.send(.message(.error(GameServerError(
				code: .notPlayerTurn,
				description: "It's not your turn."
			))))
			return
		}

		guard state.gameState.apply(relativeMovement: movement) else {
			subject?.send(.message(.error(GameServerError(
				code: .invalidMovement,
				description: #"Move "\#(movement)" not valid."#
			))))
			return
		}

		subject?.send(.message(.gameState(GameState(from: state.gameState))))
		if state.gameState.hasGameEnded {
			subject?.send(.message(.gameOver(state.winner)))
		} else {
			state.playNextMove()
			subject?.send(.message(.gameState(GameState(from: state.gameState))))
			if state.gameState.hasGameEnded {
				subject?.send(.message(.gameOver(state.winner)))
			}
		}
	}

	private func playFirstMove() {
		guard let state = state else { return }
		state.playFirstMove()
		subject?.send(.message(.gameState(GameState(from: state.gameState))))
	}
}

// MARK: - LocalGameState

protocol LocalGameState {
	var gameState: GameState { get set }
	var isPlayerTurn: Bool { get }
	var winner: UUID? { get }

	func playFirstMove()
	func playNextMove()
	func forfeit() -> UUID
}

private struct AgentGameState: LocalGameState {
	var gameState: GameState
	var localPlayer: Player
	var agentConfiguration: AgentConfiguration
	var agentPlayer: AIAgent

	var isPlayerTurn: Bool {
		gameState.currentPlayer == localPlayer
	}

	var winner: UUID? {
		switch gameState.endState {
		case .draw, .none:
			return nil
		case .playerWins(.white):
			return localPlayer == .white ? Account.offline.userId : agentConfiguration.id
		case .playerWins(.black):
			return localPlayer == .white ? agentConfiguration.id : Account.offline.userId
		}
	}

	func playFirstMove() {
		guard gameState.move == 0, gameState.currentPlayer != localPlayer else { return }
		playNextMove()
	}

	func playNextMove() {
		let move = agentPlayer.playMove(in: gameState)
		gameState.apply(move)
	}

	func forfeit() -> UUID {
		Account.offline.userId
	}
}

private struct PlayerGameState: LocalGameState {
	var gameState: GameState
	var whitePlayer: UUID
	var blackPlayer: UUID

	var isPlayerTurn: Bool {
		true
	}

	var winner: UUID? {
		switch gameState.endState {
		case .draw, .none:
			return nil
		case .playerWins(.white):
			return whitePlayer
		case .playerWins(.black):
			return blackPlayer
		}
	}

	func playFirstMove() {}
	func playNextMove() {}

	func forfeit() -> UUID {
		switch gameState.currentPlayer {
		case .white:
			return whitePlayer
		case .black:
			return blackPlayer
		}
	}
}
