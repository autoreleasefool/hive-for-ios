//
//  GameState+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-26.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveEngine

extension GameState.Options {
	static let expansions = GameState.Options.allCases.filter { $0.isExpansion }.sorted()
	static let nonExpansions = GameState.Options.allCases.filter { !$0.isExpansion }.sorted()

	var isExpansion: Bool {
		switch self {
		case .mosquito, .ladyBug, .pillBug: return true
		default: return false
		}
	}
}

extension GameState.Options: Comparable {
	public static func < (lhs: GameState.Options, rhs: GameState.Options) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
}
