//
//  HiveGameClient.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation
import HiveEngine
import Regex
import Starscream

enum GameClientEvent {
	case message(GameServerMessage)
	case connected
	case closed(String, UInt16)
}

enum GameClientError: LocalizedError {
	case failedToConnect
	case webSocketError(Error?)
}

class HiveGameClient {
	var url: URL!

	private var account: Account!

	private var webSocket: WebSocket?
	private var subject: PassthroughSubject<GameClientEvent, GameClientError>?
	private(set) var isConnected: Bool = false

	init() { }

	func setAccount(to account: Account) {
		self.account = account
	}

	func openConnection() -> AnyPublisher<GameClientEvent, GameClientError> {
		if isConnected, let subject = subject {
			return subject.eraseToAnyPublisher()
		}

		let publisher = PassthroughSubject<GameClientEvent, GameClientError>()
		self.subject = publisher

		var request = URLRequest(url: url)
		account.applyAuth(to: &request)
		webSocket = WebSocket(request: request)
		webSocket?.delegate = self
		webSocket?.connect()
		return publisher.eraseToAnyPublisher()
	}

	func close(code: CloseCode? = nil) {
		webSocket?.disconnect(closeCode: code?.rawValue ?? CloseCode.normal.rawValue)
		subject?.send(completion: .finished)
	}

	func send(_ message: GameClientMessage) {
		webSocket?.send(message: message)
	}
}

// MARK: - WebSocketDelegate

extension HiveGameClient: WebSocketDelegate {
	func didReceive(event: WebSocketEvent, client: WebSocket) {
		switch event {
		case .connected:
			isConnected = true
			subject?.send(.connected)
		case .disconnected(let reason, let code):
			isConnected = false
			print("WebSocket disconnected: \(reason) with code: \(code)")
			subject?.send(.closed(reason, code))
			subject?.send(completion: .finished)
		case .cancelled:
			isConnected = false
			subject?.send(completion: .failure(.failedToConnect))
		case .error(let error):
			isConnected = false
			subject?.send(completion: .failure(.webSocketError(error)))
		case .text(let text):
			guard let message = GameServerMessage(text) else { return }
			subject?.send(.message(message))
		case .binary, .ping, .pong:
			// Ignore non-text responses
			break
		case .viabilityChanged, .reconnectSuggested:
			// No idea what these are for
			break
		}
	}
}
