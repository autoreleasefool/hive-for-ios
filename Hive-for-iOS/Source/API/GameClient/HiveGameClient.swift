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
	case alreadyConnected
	case closed(String, UInt16)
}

enum GameClientError: LocalizedError {
	case usingOfflineAccount
	case notPrepared
	case failedToConnect
	case missingURL
	case webSocketError(Error?)
}

enum HiveGameClientConfiguration {
	case offline(GameState, ComputerConfiguration)
	case online(URL, Account?)
}

protocol HiveGameClient {
	var subject: PassthroughSubject<GameClientEvent, GameClientError>? { get }
	var isConnected: Bool { get }
	var isPrepared: Bool { get }

	func prepare(configuration: HiveGameClientConfiguration)
	func openConnection() -> AnyPublisher<GameClientEvent, GameClientError>
	func reconnect() -> AnyPublisher<GameClientEvent, GameClientError>
	func close()
	func send(_ message: GameClientMessage)
}
