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
import WebSocketKit
import NIOWebSocket

enum GameClientEvent {
	case message(GameServerMessage)
	case connected
	case closed(WebSocketErrorCode?)
}

enum GameClientError: LocalizedError {
	case invalidURL
	case failedToConnect
}

class HiveGameClient {
	var url: URL!

	private let webSocketClient: WebSocketClient
	private var account: Account!

	private var webSocket: WebSocket?
	private var subject: PassthroughSubject<GameClientEvent, GameClientError>?

	init(webSocketClient: WebSocketClient) {
		self.webSocketClient = webSocketClient
	}

	var isConnected: Bool {
		!(webSocket?.isClosed ?? true)
	}

	func setAccount(to account: Account) {
		self.account = account
	}

	private func applyAuth(to headers: inout HTTPHeaders) {
		guard let token = account.token else { return }
		headers.add(name: "Authorization", value: "Bearer \(token)")
	}

	func openConnection() -> AnyPublisher<GameClientEvent, GameClientError> {
		if let subject = subject {
			return subject.eraseToAnyPublisher()
		}

		let publisher = PassthroughSubject<GameClientEvent, GameClientError>()
		self.subject = publisher

		guard let scheme = url.scheme,
			let host = url.host else {
			print("Cannot open WebSocket connection without fully-formed URL: \(String(describing: url))")
			defer {
				publisher.send(completion: .failure(.invalidURL))
				self.subject = nil
			}
			return publisher.eraseToAnyPublisher()
		}

		var headers = HTTPHeaders()
		applyAuth(to: &headers)

		self.webSocketClient.connect(
			scheme: scheme,
			host: host,
			port: 443,
			path: self.url.path,
			headers: headers
		) { [weak self] ws in
			guard let self = self else { return }
			self.webSocket = ws
			self.setupHandlers()
			publisher.send(.connected)
			self.setupHandlers()
		}.whenFailure { [weak self] error in
			print("Failed to connect to WebSocket: \(error)")
			publisher.send(completion: .failure(.failedToConnect))
			self?.subject = nil
		}

		return publisher.eraseToAnyPublisher()
	}

	func setupHandlers() {
		webSocket?.onClose.whenComplete { [weak self] _ in
			self?.subject?.send(.closed(self?.webSocket?.closeCode))
		}

		webSocket?.onText { [weak self] _, text in
			guard let self = self, let message = GameServerMessage(text) else { return }
			self.subject?.send(.message(message))
		}
	}

	@discardableResult
	func close(code: WebSocketErrorCode? = nil) -> EventLoopFuture<Void>? {
		let future = webSocket?.close(code: code ?? .normalClosure)
		subject?.send(completion: .finished)
		return future
	}

	func send(_ message: GameClientMessage) {
		webSocket?.send(message: message)
	}
}
