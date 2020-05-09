//
//  ClientInteractor.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-05.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation
import Starscream

protocol ClientInteractor {
	func openConnection(to url: URL) -> AnyPublisher<GameClientEvent, GameClientError>
	func subscribe() -> AnyPublisher<GameClientEvent, GameClientError>?

	func closeConnection(code: CloseCode?)
	func send(_ message: GameClientMessage)
}

struct LiveClientInteractor: ClientInteractor {
	private let client: HiveGameClient
	private let appState: Store<AppState>

	init(client: HiveGameClient, appState: Store<AppState>) {
		self.client = client
		self.appState = appState
	}

	func openConnection(to url: URL) -> AnyPublisher<GameClientEvent, GameClientError> {
		client.openConnection(to: url, withAccount: appState.value.account.value)
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	func subscribe() -> AnyPublisher<GameClientEvent, GameClientError>? {
		client.subject?
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	func closeConnection(code: CloseCode?) {
		client.close(code: code)
	}

	func send(_ message: GameClientMessage) {
		client.send(message)
	}
}

struct StubClientInteractor: ClientInteractor {
	func openConnection(to url: URL) -> AnyPublisher<GameClientEvent, GameClientError> {
		Future { promise in promise(.failure(.failedToConnect)) }
			.eraseToAnyPublisher()
	}

	func subscribe() -> AnyPublisher<GameClientEvent, GameClientError>? {
		Future { promise in promise(.failure(.failedToConnect)) }
			.eraseToAnyPublisher()
	}

	func closeConnection(code: CloseCode?) { }
	func send(_ message: GameClientMessage) { }
}
