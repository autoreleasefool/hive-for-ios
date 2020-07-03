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

class LocalGameClient: HiveGameClient {
	private var gameState: GameState?
	private var computerPlayer: ComputerPlayer?

	private(set) var subject: PassthroughSubject<GameClientEvent, GameClientError>?

	var isConnected: Bool {
		subject != nil
	}

	var isPrepared: Bool {
		gameState != nil && computerPlayer != nil
	}

	func prepare(configuration: HiveGameClientConfiguration) {
		guard case let .offline(gameState, computerConfiguration) = configuration else { return }
		computerPlayer = computerConfiguration.player
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
		computerPlayer = nil
		gameState = nil
		subject = nil
	}

	func send(_ message: GameClientMessage) {
		switch message {
		case .forfeit:
			playerForfeit()
		case .movement(let movement):
			playerMovement(movement)
		case .message, .readyToPlay, .setOption:
			// Ignored for offline play
			break
		}
	}
}

// MARK: - Player actions

extension LocalGameClient {
	private func playerForfeit() {
		subject?.send(.message(.forfeit(Match.User.offlineId)))
	}

	private func playerMovement(_ movement: RelativeMovement) {

	}
}

//extension OnlineGameClient: WebSocketDelegate {
//	func didReceive(event: WebSocketEvent, client: WebSocket) {
//		switch event {
//		case .connected:
//			isConnected = true
//			subject?.send(.connected)
//		case .disconnected(let reason, let code):
//			isConnected = false
//			print("WebSocket disconnected: \(reason) with code: \(code)")
//			subject?.send(.closed(reason, code))
//			subject?.send(completion: .finished)
//		case .cancelled:
//			isConnected = false
//			subject?.send(completion: .failure(.failedToConnect))
//		case .error(let error):
//			isConnected = false
//			subject?.send(completion: .failure(.webSocketError(error)))
//		case .text(let text):
//			guard let message = GameServerMessage(text) else { return }
//			subject?.send(.message(message))
//		case .binary, .ping, .pong:
//			// Ignore non-text responses
//			break
//		case .viabilityChanged, .reconnectSuggested:
//			// viabilityChanged -- when connection goes down/up
//			// reconnectSuggested -- when a better connection is available
//			break
//		}
//	}
//}
