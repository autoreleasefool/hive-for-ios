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
	private var webSocket: WebSocket?
	private var subject: PassthroughSubject<GameClientEvent, GameClientError>?

	init(webSocketClient: WebSocketClient) {
		self.webSocketClient = webSocketClient
	}

	var isConnected: Bool {
		!(webSocket?.isClosed ?? true)
	}

	func openConnection() -> AnyPublisher<GameClientEvent, GameClientError> {
		if let subject = subject {
			return subject.eraseToAnyPublisher()
		}

		let publisher = PassthroughSubject<GameClientEvent, GameClientError>()
		self.subject = publisher

		guard let scheme = url.scheme,
			let host = url.host else {
			print("Cannot open WebSocket connection without fully-formed URL: \(url)")
			DispatchQueue.main.async { [weak self] in
				publisher.send(completion: .failure(.invalidURL))
				self?.subject = nil
			}
			return publisher.eraseToAnyPublisher()
		}

		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			guard let self = self else { return }

			do {
				try self.webSocketClient.connect(
					scheme: scheme,
					host: host,
					port: 80,
					path: self.url.path,
					headers: HTTPHeaders()
				) { [weak self] ws in
					guard let self = self else { return }
					self.webSocket = ws
					self.setupHandlers()
					publisher.send(.connected)
					self.setupHandlers()
				}.wait()
			} catch {
				print("Failed to connect to WebSocket: \(error)")
				publisher.send(completion: .failure(.failedToConnect))
				self.subject = nil
			}
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
