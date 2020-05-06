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
	func openConnection(to url: URL, subscriber: AnySubscriber<GameClientEvent, GameClientError>)
	func subscribe(_ subscriber: AnySubscriber<GameClientEvent, GameClientError>)

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

	func openConnection(
		to url: URL,
		subscriber: AnySubscriber<GameClientEvent, GameClientError>
	) {
		client.openConnection(to: url, withAccount: appState.value.account.value)
			.receive(on: DispatchQueue.main)
			.subscribe(subscriber)
	}

	func subscribe(_ subscriber: AnySubscriber<GameClientEvent, GameClientError>) {
		client.subject?
			.receive(on: DispatchQueue.main)
			.subscribe(subscriber)
	}

	func closeConnection(code: CloseCode?) {
		client.close(code: code)
	}

	func send(_ message: GameClientMessage) {
		client.send(message)
	}
}

struct StubClientInteractor: ClientInteractor {
	func openConnection(to url: URL, subscriber: AnySubscriber<GameClientEvent, GameClientError>) { }
	func subscribe(_ subscriber: AnySubscriber<GameClientEvent, GameClientError>) { }
	func closeConnection(code: CloseCode?) { }
	func send(_ message: GameClientMessage) { }
}
