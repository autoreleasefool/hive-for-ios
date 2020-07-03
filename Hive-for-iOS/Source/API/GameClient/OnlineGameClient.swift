//
//  OnlineGameClient.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation
import HiveEngine
import Starscream

class OnlineGameClient: HiveGameClient {
	static let maxReconnectAttempts = 5

	private var url: URL?
	private var account: Account?
	private var webSocket: WebSocket?

	private(set) var subject: PassthroughSubject<GameClientEvent, GameClientError>?
	private(set) var isConnected: Bool = false

	var isPrepared: Bool {
		url != nil
	}

	func prepare(configuration: HiveGameClientConfiguration) {
		guard case let .online(url, account) = configuration else { return }

		if self.url != nil, self.url != url {
			close()
		}

		self.url = url
		self.account = account
	}

	func openConnection() -> AnyPublisher<GameClientEvent, GameClientError> {
		guard isPrepared, let url = url else {
			return Fail(error: .notPrepared).eraseToAnyPublisher()
		}

		guard account?.isOffline != true else {
			return Fail(error: .usingOfflineAccount).eraseToAnyPublisher()
		}

		if isConnected, let subject = subject {
			subject.send(.alreadyConnected)
			return subject.eraseToAnyPublisher()
		}

		return openConnection(to: url, withAccount: account)
	}

	func reconnect() -> AnyPublisher<GameClientEvent, GameClientError> {
		guard isPrepared, let url = url else {
			return Fail(error: .notPrepared).eraseToAnyPublisher()
		}

		guard account?.isOffline != true else {
			return Fail(error: .usingOfflineAccount).eraseToAnyPublisher()
		}

		if isConnected, let subject = subject {
			subject.send(.alreadyConnected)
			return subject.eraseToAnyPublisher()
		}

		return openConnection(to: url, withAccount: account)
	}

	private func openConnection(
		to url: URL,
		withAccount account: Account?
	) -> AnyPublisher<GameClientEvent, GameClientError> {
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

	func close() {
		webSocket?.disconnect(closeCode: CloseCode.normal.rawValue)
		subject?.send(completion: .finished)
		subject = nil
	}

	func send(_ message: GameClientMessage) {
		webSocket?.send(message: message)
	}
}

// MARK: - WebSocketDelegate

extension OnlineGameClient: WebSocketDelegate {
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
