//
//  Preferences.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-17.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

struct Preferences: Equatable {
	var gameMode: GameMode = .sprite
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
