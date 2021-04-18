//
//  OnlineGameClient.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2020-07-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation
import HiveEngine

public class OnlineGameClient: NSObject, GameClient, URLSessionWebSocketDelegate {
	public static let maxReconnectAttempts = 5

	private var url: URL?
	private var account: Account?
	private var pingTimer: Timer?
	fileprivate var webSocket: URLSessionWebSocketTask?

	private var session: URLSession!
	private let requestQueue: DispatchQueue
	private let operationQueue = OperationQueue()

	public private(set) var subject: PassthroughSubject<GameClientEvent, GameClientError>?

	public var isPrepared: Bool {
		url != nil
	}

	public init(
		configuration: URLSessionConfiguration = .default,
		queue: DispatchQueue = DispatchQueue(label: "ca.josephroque.HiveFoundation.gameClient.requestQueue")
	) {
		self.requestQueue = queue
		self.operationQueue.underlyingQueue = requestQueue
		super.init()

		self.session = URLSession(
			configuration: configuration,
			delegate: self,
			delegateQueue: operationQueue
		)
	}

	public func prepare(configuration: GameClientConfiguration) {
		guard case let .online(url, account) = configuration else { return }

		if self.url != nil, self.url != url {
			close()
		}

		self.url = url
		self.account = account
	}

	public func openConnection() -> AnyPublisher<GameClientEvent, GameClientError> {
		guard isPrepared, let url = url else {
			return Fail(error: .notPrepared).eraseToAnyPublisher()
		}

		guard account?.isOffline != true else {
			return Fail(error: .usingOfflineAccount).eraseToAnyPublisher()
		}

		if let subject = subject {
			defer {
				// Send a `alreadyConnected` message after the publisher has been returned
				DispatchQueue.main.async {
					subject.send(.alreadyConnected)
				}
			}
			return subject.eraseToAnyPublisher()
		}

		return openConnection(to: url, withAccount: account)
	}

	public func reconnect() -> AnyPublisher<GameClientEvent, GameClientError> {
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
			switch result {
			case .success(let message):
				switch message {
				case .string(let string):
					self?.didReceive(string: string)
				case .data: break
				@unknown default: break
				}

				// Queue up to received next response, only after successful responses
				self?.setupWebSocketReceiver()
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

	public func close() {
		guard let subject = self.subject else { return }
		self.subject = nil
		cancelPingTimer()
		webSocket?.cancel(with: .normalClosure, reason: nil)
		subject.send(completion: .finished)
	}

	public func send(_ message: GameClientMessage, completionHandler: ((Error?) -> Void)?) {
		webSocket?.send(message: message) { error in completionHandler?(error) }
	}

	private func didReceive(string: String) {
		guard let message = GameServerMessage(string) else { return }
		subject?.send(.message(message))
	}

	private func didReceive(error: Error) {
		print("Recieved WebSocket error: \(error)")
		subject?.send(completion: .failure(.webSocketError(error)))
		close()
	}
}

// MARK: URLSessionDelegate

extension OnlineGameClient {
	public func urlSession(
		_ session: URLSession,
		webSocketTask: URLSessionWebSocketTask,
		didOpenWithProtocol protocol: String?
	) {
		self.subject?.send(.connected)
	}

	public func urlSession(
		_ session: URLSession,
		webSocketTask: URLSessionWebSocketTask,
		didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
		reason: Data?
	) {
		if subject != nil {
			close()
		}
	}
}
