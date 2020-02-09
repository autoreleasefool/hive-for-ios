//
//  GameState+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-26.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveEngine

typealias Piece = HiveEngine.Unit

extension Piece.Class: Identifiable {
	public var id: String {
		return description
	}
}

extension GameState.Option {
	static let expansions = GameState.Option.allCases.filter { $0.isExpansion }.sorted()
	static let nonExpansions = GameState.Option.allCases.filter { !$0.isExpansion }.sorted()

	var isExpansion: Bool {
		switch self {
		case .mosquito, .ladyBug, .pillBug: return true
		default: return false
		}
	}
}

extension GameState.Option: Comparable {
	public static func < (lhs: GameState.Option, rhs: GameState.Option) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
}
