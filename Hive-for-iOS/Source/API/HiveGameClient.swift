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
	static let maxReconnectAttempts = 5

	private var url: URL?
	private var webSocket: WebSocket?
	private(set) var subject: PassthroughSubject<GameClientEvent, GameClientError>?
	private(set) var isConnected: Bool = false

	func openConnection(to url: URL, withAccount account: Account?) -> AnyPublisher<GameClientEvent, GameClientError> {
		if isConnected, let subject = subject {
			if self.url == url {
				return subject.eraseToAnyPublisher()
			} else {
				close()
			}
		}

		self.url = url
		let publisher = PassthroughSubject<GameClientEvent, GameClientError>()
		self.subject = publisher

		var request = URLRequest(url: url)
		request.timeoutInterval = 10
		account?.applyAuth(to: &request)
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
			// viabilityChanged -- when connection goes down/up
			// reconnectSuggested -- when a better connection is available
			break
		}
	}
}
