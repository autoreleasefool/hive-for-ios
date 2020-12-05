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

	var hasDisabledEmojiReactions: Bool {
		get { UserDefaults.standard.bool(forKey: Key.disabledEmojiReactions.rawValue) }
		set { UserDefaults.standard.set(newValue, forKey: Key.disabledEmojiReactions.rawValue) }
	}

	var pieceColorScheme: PieceColorScheme {
		get {
			PieceColorScheme(
				rawValue: UserDefaults.standard.string(forKey: Key.pieceColorScheme.rawValue) ?? ""
			) ?? .outlined
		}
		set { UserDefaults.standard.set(newValue.rawValue, forKey: Key.pieceColorScheme.rawValue) }
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

private extension Preferences {
	enum Key: String {
		case gameMode
		case disabledEmojiReactions
		case pieceColorScheme
	}
}
