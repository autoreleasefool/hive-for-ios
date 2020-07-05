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
	func prepare(_ configuration: ClientInteractorConfiguration, clientConfiguration: GameClientConfiguration)
	func openConnection(_ configuration: ClientInteractorConfiguration) -> AnyPublisher<GameClientEvent, GameClientError>
	func reconnect(_ configuration: ClientInteractorConfiguration) -> AnyPublisher<GameClientEvent, GameClientError>

	func close(_ configuration: ClientInteractorConfiguration)
	func send(_ configuration: ClientInteractorConfiguration, _ message: GameClientMessage)
}

enum ClientInteractorConfiguration {
	case online
	case local
}

struct LiveClientInteractor: ClientInteractor {
	struct Clients {
		let online: GameClient
		let local: GameClient
	}

	private let clients: Clients
	private let appState: Store<AppState>

	init(clients: Clients, appState: Store<AppState>) {
		self.clients = clients
		self.appState = appState
	}

	func prepare(_ configuration: ClientInteractorConfiguration, clientConfiguration: GameClientConfiguration) {
		client(forConfiguration: configuration).prepare(configuration: clientConfiguration)
	}

	func openConnection(
		_ configuration: ClientInteractorConfiguration
	) -> AnyPublisher<GameClientEvent, GameClientError> {
		client(forConfiguration: configuration)
			.openConnection()
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
	}

	func reconnect(_ configuration: ClientInteractorConfiguration) -> AnyPublisher<GameClientEvent, GameClientError> {
		client(forConfiguration: configuration)
			.reconnect()
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
	}

	func close(_ configuration: ClientInteractorConfiguration) {
		client(forConfiguration: configuration)
			.close()
	}

	func send(_ configuration: ClientInteractorConfiguration, _ message: GameClientMessage) {
		client(forConfiguration: configuration)
			.send(message)
	}

	private func client(forConfiguration: ClientInteractorConfiguration) -> GameClient {
		switch forConfiguration {
		case .online: return clients.online
		case .local: return clients.local
		}
	}
}

struct StubClientInteractor: ClientInteractor {
	func prepare(_ configuration: ClientInteractorConfiguration, clientConfiguration: GameClientConfiguration) { }

	func openConnection(_ configuration: ClientInteractorConfiguration) -> AnyPublisher<GameClientEvent, GameClientError> {
		Fail(error: .failedToConnect).eraseToAnyPublisher()
	}

	func reconnect(_ configuration: ClientInteractorConfiguration) -> AnyPublisher<GameClientEvent, GameClientError> {
		Fail(error: .failedToConnect).eraseToAnyPublisher()
	}

	func close(_ configuration: ClientInteractorConfiguration) { }
	func send(_ configuration: ClientInteractorConfiguration, _ message: GameClientMessage) { }
}
