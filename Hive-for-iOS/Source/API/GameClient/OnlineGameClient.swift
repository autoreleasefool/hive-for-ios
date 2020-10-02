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

class OnlineGameClient: GameClient {
	static let maxReconnectAttempts = 5

	private var url: URL?
	private var account: Account?
	private var webSocket: URLSessionWebSocketTask?
	private var pingTimer: Timer?
	private lazy var session = URLSession(configuration: .default)

	private(set) var subject: PassthroughSubject<GameClientEvent, GameClientError>?

	var isPrepared: Bool {
		url != nil
	}

	func prepare(configuration: GameClientConfiguration) {
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

		if let subject = subject {
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

		if let subject = subject {
			subject.send(.alreadyConnected)
			return subject.eraseToAnyPublisher()
		}

		return openConnection(to: url, withAccount: account)
	}

	private func openConnection(
		to url: URL,
		withAccount account: Account?
	) -> AnyPublisher<GameClientEvent, GameClientError> {
		defer {
			// Send a `connected` message after the publisher has been returned
			DispatchQueue.main.async { [weak self] in
				self?.subject?.send(.connected)
			}
		}

		let publisher = PassthroughSubject<GameClientEvent, GameClientError>()
		self.subject = publisher

		var request = URLRequest(url: url)
		request.timeoutInterval = 10
		account?.applyAuth(to: &request)
		webSocket = session.webSocketTask(with: request)
		setupWebSocketReceiver()
		setupPingTimer()

		webSocket?.resume()
		return publisher.eraseToAnyPublisher()
	}

	private func setupWebSocketReceiver() {
		webSocket?.receive { [weak self] result in
			defer { self?.setupWebSocketReceiver() }
			switch result {
			case .success(let message):
				switch message {
				case .string(let string):
					self?.didReceive(string: string)
				case .data: break
				@unknown default: break
				}
			case .failure(let error):
				self?.didReceive(error: error)
			}
		}
	}

	private func cancelPingTimer() {
		pingTimer?.invalidate()
		pingTimer = nil
	}

	private func setupPingTimer() {
		cancelPingTimer()
		pingTimer = Timer(timeInterval: 30, repeats: true) { [weak self] _ in
			self?.webSocket?.sendPing { _ in }
		}
	}

	func close() {
		cancelPingTimer()
		webSocket?.cancel(with: .normalClosure, reason: nil)
		subject?.send(completion: .finished)
		subject = nil
	}

	func send(_ message: GameClientMessage, completionHandler: ((Error?) -> Void)?) {
		webSocket?.send(message: message) { error in completionHandler?(error) }
	}

	private func didReceive(string: String) {
		guard let message = GameServerMessage(string) else { return }
		subject?.send(.message(message))
	}

	private func didReceive(error: Error) {
		subject?.send(completion: .failure(.webSocketError(error)))
		close()
	}
}
