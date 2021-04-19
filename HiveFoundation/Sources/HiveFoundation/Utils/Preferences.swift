//
//  Preferences.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2020-05-17.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

public struct Preferences: Equatable {

	public static let shared = Preferences()

	#if os(iOS)
	public var gameMode: GameMode {
		get { GameMode(rawValue: UserDefaults.standard.string(forKey: Key.gameMode.rawValue) ?? "") ?? .sprite }
		set { UserDefaults.standard.set(newValue.rawValue, forKey: Key.gameMode.rawValue) }
	}

	public var isEmotesEnabled: Bool {
		get { bool(for: Key.isEmotesEnabled, defaultValue: true) }
		set { UserDefaults.standard.set(newValue, forKey: Key.isEmotesEnabled.rawValue) }
	}

	public var isSpectatorEmotesEnabled: Bool {
		get { bool(for: Key.isSpectatorEmotesEnabled, defaultValue: true) }
		set { UserDefaults.standard.set(newValue, forKey: Key.isSpectatorEmotesEnabled.rawValue) }
	}

	public var isSpectatorNotificationsEnabled: Bool {
		get { bool(for: Key.isSpectatorNotificationsEnabled, defaultValue: true) }
		set { UserDefaults.standard.set(newValue, forKey: Key.isSpectatorNotificationsEnabled.rawValue) }
	}

	public var hasDismissedReplayTooltip: Bool {
		get { bool(for: Key.hasDismissedReplayTooltip, defaultValue: false) }
		set { UserDefaults.standard.set(newValue, forKey: Key.hasDismissedReplayTooltip.rawValue) }
	}

	public var isMoveToCenterOnRotateEnabled: Bool {
		get { bool(for: Key.isMoveToCenterOnRotateEnabled, defaultValue: true) }
		set { UserDefaults.standard.set(newValue, forKey: Key.isMoveToCenterOnRotateEnabled.rawValue) }
	}
	#endif

	public var pieceColorScheme: PieceColorScheme {
		get {
			PieceColorScheme(
				rawValue: UserDefaults.standard.string(forKey: Key.pieceColorScheme.rawValue) ?? ""
			) ?? .outlined
		}
		set { UserDefaults.standard.set(newValue.rawValue, forKey: Key.pieceColorScheme.rawValue) }
	}

	private func bool(for key: Key, defaultValue: Bool) -> Bool {
		guard UserDefaults.standard.object(forKey: key.rawValue) != nil else {
			return defaultValue
		}
		return UserDefaults.standard.bool(forKey: key.rawValue)
	}
}

// MARK: - Game Mode

#if os(iOS)
extension Preferences {
	public enum GameMode: String, CaseIterable, CustomStringConvertible, Identifiable {
		case ar = "AR"
		case sprite = "2D"

		public var id: String {
			rawValue
		}

		public var description: String {
			rawValue
		}
	}
}
#endif

// MARK: - Color scheme

extension Preferences {
	public enum PieceColorScheme: String, CaseIterable, CustomStringConvertible, Identifiable {
		case filled = "Filled"
		case outlined = "Outlined"

		public var id: String {
			rawValue
		}

		public var description: String {
			rawValue
		}
	}
}

// MARK: - Keys

extension Preferences {
	public enum Key: String {
		#if os(iOS)
		case gameMode
		case isEmotesEnabled
		case hasDismissedReplayTooltip
		case isSpectatorEmotesEnabled
		case isSpectatorNotificationsEnabled
		case isMoveToCenterOnRotateEnabled
		#endif

		case pieceColorScheme
	}
}
