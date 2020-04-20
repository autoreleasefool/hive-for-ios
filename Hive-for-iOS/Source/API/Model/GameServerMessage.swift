//
//  GameServerMessage.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-06.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine

enum GameServerMessage {
	case gameState(GameState)
	case setOption(GameState.Option, Bool)
	case playerReady(UUID, Bool)
	case playerJoined(UUID)
	case playerLeft(UUID)
	case message(UUID, String)
	case forfeit(UUID)
	case gameOver(UUID?)
	case error(GameServerError)

	init?(_ message: String) {
		if message.hasPrefix("STATE") {
			guard let state = GameServerMessage.extractState(from: message) else { return nil }
			self = .gameState(state)
		} else if message.hasPrefix("SET") {
			guard let option = GameServerMessage.extractOption(from: message),
				let value = GameServerMessage.extractBoolean(from: message) else { return nil }
			self = .setOption(option, value)
		} else if message.hasPrefix("READY") {
			guard let userId = GameServerMessage.extractUserId(from: message),
				let isReady = GameServerMessage.extractBoolean(from: message) else { return nil }
			self = .playerReady(userId, isReady)
		} else if message.hasPrefix("MSG") {
			guard let userId = GameServerMessage.extractUserId(from: message),
				let userMessage = GameServerMessage.extractMessage(withId: userId, from: message) else { return nil }
			self = .message(userId, userMessage)
		} else if message.hasPrefix("FF") {
			guard let userId = GameServerMessage.extractUserId(from: message) else { return nil }
			self = .forfeit(userId)
		} else if message.hasPrefix("JOIN") {
			guard let userId = GameServerMessage.extractUserId(from: message) else { return nil}
			self = .playerJoined(userId)
		} else if message.hasPrefix("LEAVE") {
			guard let userId = GameServerMessage.extractUserId(from: message) else { return nil}
			self = .playerLeft(userId)
		} else if message.hasPrefix("WINNER") {
			let userId = GameServerMessage.extractUserId(from: message)
			self = .gameOver(userId)
		} else if message.hasPrefix("ERR") {
			let error = GameServerMessage.extractError(from: message)
			self = .error(error)
		} else {
			print("Failed to parse GameServerMessage: \(message)")
			return nil
		}
	}
}

// MARK: - GameState

extension GameServerMessage {
	static func extractState(from message: String) -> GameState? {
		GameString(from: String(message.substring(from: 6)))?.state
	}
}

// MARK: - GameState.Option

extension GameServerMessage {
	static func extractOption(from message: String) -> GameState.Option? {
		guard let optionStart = message.firstIndex(of: " "),
			let optionEnd = message.lastIndex(of: " "),
			let option = GameState.Option(
				rawValue: String(message[optionStart...optionEnd]).trimmingCharacters(in: .whitespaces)
			) else {
			return nil
		}

		return option
	}

	static func extractBoolean(from message: String) -> Bool? {
		guard let valueStart = message.lastIndex(of: " "),
			let value = Bool(String(message[valueStart...]).trimmingCharacters(in: .whitespaces)) else {
			return nil
		}

		return value
	}
}

// MARK: - UUID

extension GameServerMessage {
	static func extractUserId(from message: String) -> UUID? {
		guard let idStart = message.firstIndex(of: " ") else { return nil }
		let idEnd = message[message.index(idStart, offsetBy: 1)...].firstIndex(of: " ") ?? message.endIndex
		return UUID(uuidString: String(message[idStart...idEnd]).trimmingCharacters(in: .whitespaces))
	}
}

// MARK: - Message

extension GameServerMessage {
	static func extractMessage(withId id: UUID, from message: String) -> String? {
		guard let idStart = message.firstIndex(of: " ") else { return nil }
		let messageStart = message.index(idStart, offsetBy: id.uuidString.count)
		return String(message[messageStart...]).trimmingCharacters(in: .whitespaces)
	}
}

// MARK: - GameServerError

struct GameServerError {
	fileprivate static var UNKNOWN: GameServerError {
		GameServerError("ERR null 999 Unknown error")!
	}

	enum Code: Int {
		case invalidMovement = 101
		case notPlayerTurn = 102
		case optionNonModifiable = 103
		case invalidCommand = 199
		case optionValueNotUpdated = 201
		case unknownError = 999
	}

	let user: UUID?
	let code: Code
	let description: String

	init?(_ message: String) {
		let components = message.split(separator: " ")
		guard components.count >= 4 else { return nil }
		user = UUID(uuidString: String(components[1]))
		code = Code(rawValue: Int(String(components[2])) ?? 999) ?? .unknownError
		description = components[3...].joined(separator: " ")
	}

	var loaf: LoafState {
		return LoafState("\(description) (\(code))", state: .error)
	}
}

extension GameServerMessage {
	static func extractError(from message: String) -> GameServerError {
		GameServerError(message) ?? GameServerError.UNKNOWN
	}
}
