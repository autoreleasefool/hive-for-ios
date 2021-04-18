//
//  GameServerMessage.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2020-04-06.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine

public enum GameServerMessage {
	public enum Option {
		case gameOption(GameState.Option)
		case customOption(String)
	}

	case gameState(GameState)
	case setOption(Option, Bool)
	case playerReady(UUID, Bool)
	case playerJoined(UUID)
	case playerLeft(UUID)
	case spectatorJoined(name: String)
	case spectatorLeft(name: String)
	case message(UUID, String)
	case forfeit(UUID)
	case gameOver(UUID?)
	case error(GameServerError)

	public init?(_ message: String) {
		if message.hasPrefix("STATE") {
			guard let state = GameServerMessage.extractState(from: message) else { return nil }
			self = .gameState(state)
		} else if message.hasPrefix("SET") {
			guard let value = GameServerMessage.extractBoolean(from: message) else { return nil }

			if let option = GameServerMessage.extractOption(from: message) {
				self = .setOption(.customOption(option), value)
			} else if let gameOption = GameServerMessage.extractGameOption(from: message) {
				self = .setOption(.gameOption(gameOption), value)
			} else {
				return nil
			}
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
		} else if message.hasPrefix("SPECJOIN") {
			let string = GameServerMessage.extractString(from: message)
			self = .spectatorJoined(name: string)
		} else if message.hasPrefix("SPECLEAVE") {
			let string = GameServerMessage.extractString(from: message)
			self = .spectatorLeft(name: string)
		} else if message.hasPrefix("WINNER") {
			let userId = GameServerMessage.extractUserId(from: message)
			self = .gameOver(userId)
		} else if message.hasPrefix("ERR") {
			let error = GameServerMessage.extractError(from: message)
			self = .error(error)
		} else {
			logger.error("Failed to parse GameServerMessage: \(message)")
			return nil
		}
	}
}

// MARK: - GameState

extension GameServerMessage {
	static func extractState(from message: String) -> GameState? {
		GameString(from: String(message[message.index(message.startIndex, offsetBy: 6)...]))?.state
	}
}

// MARK: - GameState.Option

extension GameServerMessage {
	static func extractOption(from message: String) -> String? {
		guard let optionStart = message.firstIndex(of: " "),
			let optionEnd = message.lastIndex(of: " ") else {
			return nil
		}

		return String(message[optionStart..<optionEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
	}

	static func extractGameOption(from message: String) -> GameState.Option? {
		guard let optionStart = message.firstIndex(of: " "),
			let optionEnd = message.lastIndex(of: " "),
			let option = GameState.Option(
				rawValue: String(message[optionStart..<optionEnd]).trimmingCharacters(in: .whitespaces)
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
		return UUID(uuidString: String(message[idStart..<idEnd]).trimmingCharacters(in: .whitespaces))
	}
}

// MARK: - Message

extension GameServerMessage {
	static func extractMessage(withId id: UUID, from message: String) -> String? {
		guard let idStart = message.firstIndex(of: " ") else { return nil }
		let messageStart = message.index(idStart, offsetBy: id.uuidString.count)
		return String(message[messageStart...]).trimmingCharacters(in: .whitespaces)
	}

	static func extractString(from message: String) -> String {
		guard let messageStart = message.firstIndex(of: " ") else { return "" }
		return String(message[messageStart...]).trimmingCharacters(in: .whitespaces)
	}
}

// MARK: - GameServerError

public struct GameServerError {
	fileprivate static var UNKNOWN: GameServerError {
		GameServerError("ERR null 999 Unknown error")!
	}

	public enum Code: Int {
		case invalidMovement = 101
		case notPlayerTurn = 102
		case optionNonModifiable = 103
		case invalidCommand = 199
		case optionValueNotUpdated = 201
		case failedToEndMatch = 202
		case failedToStartMatch = 203
		case unknownError = 999
	}

	public let user: UUID?
	public let code: Code
	public let description: String

	public init?(_ message: String) {
		let components = message.split(separator: " ")
		guard components.count >= 4 else { return nil }
		user = UUID(uuidString: String(components[1]))
		code = Code(rawValue: Int(String(components[2])) ?? 999) ?? .unknownError
		description = components[3...].joined(separator: " ")
	}

	public init(user: UUID? = nil, code: Code, description: String) {
		self.user = user
		self.code = code
		self.description = description
	}
}

extension GameServerMessage {
	static func extractError(from message: String) -> GameServerError {
		GameServerError(message) ?? GameServerError.UNKNOWN
	}
}
