//
//  HiveGameClient.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine
import Regex

protocol HiveGameClientDelegate: class {
	func clientDidConnect(_ hiveGameClient: HiveGameClient)
	func clientDidDisconnect(_ hiveGameClient: HiveGameClient, error: DisconnectError?)
	func clientDidReceiveMessage(_ hiveGameClient: HiveGameClient, response: GameClientResponse)
}

class HiveGameClient {
	private static var baseURL: URL {
		return URL(string: "https://example.com")!
	}

	weak var delegate: HiveGameClientDelegate?

	func openConnection() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.delegate?.clientDidConnect(self)
		}
	}

	func closeConnection() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.delegate?.clientDidDisconnect(self, error: nil)
		}
	}

	func send(_ message: GameClientMessage) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			#warning("TODO: Send message to server")

			#warning("TODO: remove mock response from server")
			if let response = self.mockResponse(to: message) {
				self.delegate?.clientDidReceiveMessage(self, response: response)
			}
		}
	}
}

// MARK: - Message

enum GameClientMessage {
	case movement(Movement, GameState)

	var rawValue: String {
		switch self {
		case .movement(let movement, let state):
			return movement.notation(in: state)
		}
	}
}

// MARK: - Response

enum GameClientResponse {
	case movement(RelativeMovement)

	init?(_ message: String) {
		if message.hasPrefix("MOVE:"),
			let movement = RelativeMovement(notation: message.substring(from: 5)) {
			self = .movement(movement)
		}

		return nil
	}
}

// MARK: - Error

enum DisconnectError: LocalizedError {
	case unknown

	var localizedDescription: String {
		switch self {
		case .unknown: return "Unknown"
		}
	}
}

// MARK: - Mocking

extension HiveGameClient {
	fileprivate func mockResponse(to message: GameClientMessage) -> GameClientResponse? {
		switch message {
		case .movement(let movement, let state):
			let copy = GameState(from: state)
			copy.apply(movement)
			return .movement(copy.availableMoves.randomElement()!.relative(in: copy)!)
		}
	}
}
