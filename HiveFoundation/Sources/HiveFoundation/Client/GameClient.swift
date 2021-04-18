//
//  GameClient.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation
import HiveEngine

public enum GameClientEvent {
	case message(GameServerMessage)
	case connected
	case alreadyConnected
}

public enum GameClientError: LocalizedError {
	case usingOfflineAccount
	case notPrepared
	case failedToConnect
	case missingURL
	case webSocketError(Error?)
}

public enum GameClientConfiguration {
	case online(URL, Account?)
	case local(GameState, whitePlayer: UUID, blackPlayer: UUID)
	case agent(GameState, Player, AgentConfiguration)
}

public protocol GameClient {
	var subject: PassthroughSubject<GameClientEvent, GameClientError>? { get }
	var isPrepared: Bool { get }

	func prepare(configuration: GameClientConfiguration)
	func openConnection() -> AnyPublisher<GameClientEvent, GameClientError>
	func reconnect() -> AnyPublisher<GameClientEvent, GameClientError>
	func close()
	func send(_ message: GameClientMessage, completionHandler: ((Error?) -> Void)?)
}
