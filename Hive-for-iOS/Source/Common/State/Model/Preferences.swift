//
//  Preferences.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-17.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

struct Preferences: Equatable {
	var gameMode: GameMode {
		get { GameMode(rawValue: UserDefaults.standard.string(forKey: Key.gameMode.rawValue) ?? "") ?? .sprite }
		set { UserDefaults.standard.set(newValue.rawValue, forKey: Key.gameMode.rawValue) }
	}

	var pieceColorScheme: PieceColorScheme {
		get {
			PieceColorScheme(
				rawValue: UserDefaults.standard.string(forKey: Key.pieceColorScheme.rawValue) ?? ""
			) ?? .outlined
		}
		set { UserDefaults.standard.set(newValue.rawValue, forKey: Key.pieceColorScheme.rawValue) }
	}

	var isEmotesEnabled: Bool {
		get { bool(for: Key.isEmotesEnabled, defaultValue: true) }
		set { UserDefaults.standard.set(newValue, forKey: Key.isEmotesEnabled.rawValue) }
	}

	var isSpectatorEmotesEnabled: Bool {
		get { bool(for: Key.isSpectatorEmotesEnabled, defaultValue: true) }
		set { UserDefaults.standard.set(newValue, forKey: Key.isSpectatorEmotesEnabled.rawValue) }
	}

	var isSpectatorNotificationsEnabled: Bool {
		get { bool(for: Key.isSpectatorNotificationsEnabled, defaultValue: true) }
		set { UserDefaults.standard.set(newValue, forKey: Key.isSpectatorNotificationsEnabled.rawValue) }
	}

	var hasDismissedReplayTooltip: Bool {
		get { bool(for: Key.hasDismissedReplayTooltip, defaultValue: false) }
		set { UserDefaults.standard.set(newValue, forKey: Key.hasDismissedReplayTooltip.rawValue) }
	}

	var isMoveToCenterOnRotateEnabled: Bool {
		get { bool(for: Key.isMoveToCenterOnRotateEnabled, defaultValue: true) }
		set { UserDefaults.standard.set(newValue, forKey: Key.isMoveToCenterOnRotateEnabled.rawValue) }
	}

	private func bool(for key: Key, defaultValue: Bool) -> Bool {
		guard UserDefaults.standard.object(forKey: key.rawValue) != nil else {
			return defaultValue
		}
		return UserDefaults.standard.bool(forKey: key.rawValue)
	}
}

// MARK: - Game Mode

extension Preferences {
	enum GameMode: String, CaseIterable, CustomStringConvertible, Identifiable {
		case ar = "AR"
		case sprite = "2D"

		var id: String {
			rawValue
		}

		var description: String {
			rawValue
		}
	}
}

// MARK: - Color scheme

extension Preferences {
	enum PieceColorScheme: String, CaseIterable, CustomStringConvertible, Identifiable {
		case filled = "Filled"
		case outlined = "Outlined"

		var id: String {
			rawValue
		}

		var description: String {
			rawValue
		}
	}
}

// MARK: - Keys

extension Preferences {
	enum Key: String {
		case gameMode
		case isEmotesEnabled
		case pieceColorScheme
		case hasDismissedReplayTooltip
		case isSpectatorEmotesEnabled
		case isSpectatorNotificationsEnabled
		case isMoveToCenterOnRotateEnabled
	}
}
