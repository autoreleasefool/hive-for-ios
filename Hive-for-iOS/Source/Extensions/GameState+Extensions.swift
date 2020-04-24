//
//  GameState+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-26.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import UIKit
import HiveEngine

// MARK: - Pieces

typealias Piece = HiveEngine.Unit

extension Piece.Class: Identifiable {
	public var id: String {
		description
	}

	var image: UIImage {
		switch self {
		case .ant: return ImageAsset.Pieces.ant
		case .beetle: return ImageAsset.Pieces.beetle
		case .hopper: return ImageAsset.Pieces.hopper
		case .ladyBug: return ImageAsset.Pieces.ladyBug
		case .mosquito: return ImageAsset.Pieces.mosquito
		case .pillBug: return ImageAsset.Pieces.pillBug
		case .queen: return ImageAsset.Pieces.queen
		case .spider: return ImageAsset.Pieces.spider
		}
	}

	init?(fromName name: String) {
		switch name {
		case "Ant": self = .ant
		case "Beetle": self = .beetle
		case "Hopper": self = .hopper
		case "Lady Bug": self = .ladyBug
		case "Mosquito": self = .mosquito
		case "Pill Bug": self = .pillBug
		case "Queen": self = .queen
		case "Spider": self = .spider
		default: return nil
		}
	}

	var descriptionPlural: String {
		switch self {
		case .ant: return "Ants"
		case .beetle: return "Beetles"
		case .hopper: return "Hoppers"
		case .ladyBug: return "Lady Bugs"
		case .mosquito: return "Mosquitoes"
		case .pillBug: return "Pill Bugs"
		case .queen: return "Queens"
		case .spider: return "Spiders"
		}
	}
}

// MARK: - State

extension GameState {
	var allPiecesInHands: [Piece] {
		Array((unitsInHand[.white] ?? []).union(unitsInHand[.black] ?? []))
	}

	func firstUnplayed(of pieceClass: Piece.Class, inHand player: Player) -> Piece? {
		let unplayed = unitsInHand[player]?.filter { $0.class == pieceClass } ?? []
		guard let first = unplayed.first else { return nil }
		return unplayed.reduce(first, { (lowest, next) in next.index < lowest.index ? next : lowest })
	}

	func pieceHasMoves(_ piece: Piece) -> Bool {
		availableMoves.contains(where: { $0.movedUnit == piece })
	}

	var displayWinner: String? {
		let winner = self.winner
		if winner.count == 2 {
			return "It's a tie!"
		} else if winner.count == 1 {
			return winner.first == .white ? "White wins!" : "Black wins!"
		}

		return nil
	}

	var hiveBorder: Set<Position> {
		Set(self.stacks
			.filter { $0.value.count > 0 }
			.flatMap { $0.key.adjacent() }
			.filter { (self.stacks[$0]?.count ?? 0) == 0}
		)
	}
}

// MARK: Options

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
		lhs.rawValue < rhs.rawValue
	}
}

extension GameState.Option {
	static func parse(_ string: String) -> Set<GameState.Option> {
		var options: Set<GameState.Option> = []
		string.split(separator: ";").forEach {
			let optionAndValue = $0.split(separator: ":")
			guard optionAndValue.count == 2 else { return }
			if Bool(String(optionAndValue[1])) ?? false,
				let option = GameState.Option(rawValue: String(optionAndValue[0])) {
				options.insert(option)
			}
		}
		return options
	}

	static func encode(_ options: Set<GameState.Option>) -> String {
		GameState.Option.allCases
			.map { "\($0.rawValue):\(options.contains($0))" }
			.joined(separator: ";")
	}
}

// MARK: - Players

extension Player {
	var color: ColorAsset {
		switch self {
		case .white: return .white
		case .black: return .primary
		}
	}
}
