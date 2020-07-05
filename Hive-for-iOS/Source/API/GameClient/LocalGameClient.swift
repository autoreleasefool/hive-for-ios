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
	private var gameState: GameState?
	private var localPlayer: Player?
	private var computerConfiguration: AgentConfiguration?
	private var computerPlayer: AIAgent?

	private(set) var subject: PassthroughSubject<GameClientEvent, GameClientError>?

	var isConnected: Bool {
		subject != nil
	}

	var isPrepared: Bool {
		gameState != nil && computerPlayer != nil && localPlayer != nil && computerConfiguration != nil
	}

	func prepare(configuration: GameClientConfiguration) {
		guard case let .offline(gameState, player, computerConfiguration) = configuration else { return }
		self.gameState = gameState
		self.localPlayer = player
		self.computerConfiguration = computerConfiguration
		self.computerPlayer = computerConfiguration.player
	}

	func openConnection() -> AnyPublisher<GameClientEvent, GameClientError> {
		guard isPrepared else {
			return Fail(error: .notPrepared).eraseToAnyPublisher()
		}

		if isConnected, let subject = subject {
			subject.send(.alreadyConnected)
			return subject.eraseToAnyPublisher()
		}

		return createPublisher()
	}

	func reconnect() -> AnyPublisher<GameClientEvent, GameClientError> {
		guard isPrepared else {
			return Fail(error: .notPrepared).eraseToAnyPublisher()
		}

		if isConnected, let subject = subject {
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

	func send(_ message: GameClientMessage) {
		switch message {
		case .forfeit:
			playerForfeit()
		case .movement(let movement):
			playerMovement(movement)
		case .readyToPlay:
			playComputerMoveIfFirst()
		case .message, .setOption:
			// Ignored for offline play
			break
		}
	}

	private func resetState() {
		computerPlayer = nil
		computerConfiguration = nil
		localPlayer = nil
		gameState = nil
		subject = nil
	}
}

// MARK: - Player actions

private extension LocalGameClient {
	func playerForfeit() {
		subject?.send(.message(.forfeit(Match.User.offlineId)))
	}

	func playerMovement(_ movement: RelativeMovement) {
		guard let gameState = gameState else {
			subject?.send(.message(.error(GameServerError(
				code: .invalidCommand,
				description: "There doesn't appear to be a game in progress."
			))))
			return
		}

		guard gameState.currentPlayer == localPlayer else {
			subject?.send(.message(.error(GameServerError(
				code: .notPlayerTurn,
				description: "It's not your turn."
			))))
			return
		}

		guard gameState.apply(relativeMovement: movement) else {
			subject?.send(.message(.error(GameServerError(
				code: .invalidMovement,
				description: #"Move "\#(movement)" not valid."#
			))))
			return
		}

		subject?.send(.message(.gameState(GameState(from: gameState))))
		if gameState.hasGameEnded {
			endGame()
		} else {
			playComputerMove()
		}
	}
}

// MARK: - Computer actions

private extension LocalGameClient {
	func playComputerMoveIfFirst() {
		guard gameState?.move == 0, gameState?.currentPlayer != localPlayer else { return }
		playComputerMove()
	}

	func playComputerMove() {
		guard let gameState = gameState else {
			subject?.send(.message(.error(GameServerError(
				code: .unknownError,
				description: "There doesn't appear to be a game in progress."
			))))
			return
		}

		guard let computerMove = computerPlayer?.playMove(in: gameState),
			gameState.apply(computerMove) else {
			return
		}

		subject?.send(.message(.gameState(GameState(from: gameState))))
		if gameState.hasGameEnded {
			endGame()
		}
	}
}

// MARK: - Game actions

private extension LocalGameClient {
	var winner: UUID? {
		switch gameState?.endState {
		case .draw, .none: return nil
		case .playerWins(.black): return localPlayer == .white ? Match.User.offlineId : computerConfiguration?.id
		case .playerWins(.white): return localPlayer == .white ? computerConfiguration?.id : Match.User.offlineId
		}
	}

	func endGame() {
		guard gameState?.hasGameEnded == true else { return }
		subject?.send(.message(.gameOver(winner)))
	}
}
