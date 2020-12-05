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

extension Piece {
	var image: UIImage {
		switch self.class {
		case .ant: return owner == .white ? ImageAsset.Pieces.White.ant : ImageAsset.Pieces.Black.ant
		case .beetle: return owner == .white ? ImageAsset.Pieces.White.beetle : ImageAsset.Pieces.Black.beetle
		case .hopper: return owner == .white ? ImageAsset.Pieces.White.hopper : ImageAsset.Pieces.Black.hopper
		case .ladyBug: return owner == .white ? ImageAsset.Pieces.White.ladyBug : ImageAsset.Pieces.Black.ladyBug
		case .mosquito: return owner == .white ? ImageAsset.Pieces.White.mosquito : ImageAsset.Pieces.Black.mosquito
		case .pillBug: return owner == .white ? ImageAsset.Pieces.White.pillBug : ImageAsset.Pieces.Black.pillBug
		case .queen: return owner == .white ? ImageAsset.Pieces.White.queen : ImageAsset.Pieces.Black.queen
		case .spider: return owner == .white ? ImageAsset.Pieces.White.spider : ImageAsset.Pieces.Black.spider
		}
	}

	var filledImage: UIImage {
		switch self.class {
		case .ant: return owner == .white
			? ImageAsset.Pieces.White.Filled.ant
			: ImageAsset.Pieces.Black.Filled.ant
		case .beetle: return owner == .white
			? ImageAsset.Pieces.White.Filled.beetle
			: ImageAsset.Pieces.Black.Filled.beetle
		case .hopper: return owner == .white
			? ImageAsset.Pieces.White.Filled.hopper
			: ImageAsset.Pieces.Black.Filled.hopper
		case .ladyBug: return owner == .white
			? ImageAsset.Pieces.White.Filled.ladyBug
			: ImageAsset.Pieces.Black.Filled.ladyBug
		case .mosquito: return owner == .white
			? ImageAsset.Pieces.White.Filled.mosquito
			: ImageAsset.Pieces.Black.Filled.mosquito
		case .pillBug: return owner == .white
			? ImageAsset.Pieces.White.Filled.pillBug
			: ImageAsset.Pieces.Black.Filled.pillBug
		case .queen: return owner == .white
			? ImageAsset.Pieces.White.Filled.queen
			: ImageAsset.Pieces.Black.Filled.queen
		case .spider: return owner == .white
			? ImageAsset.Pieces.White.Filled.spider
			: ImageAsset.Pieces.Black.Filled.spider
		}
	}
}

extension Piece.Class: Identifiable {
	public var id: String {
		description
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
		switch endState {
		case .draw: return "It's a tie!"
		case .playerWins(.black): return "Black wins!"
		case .playerWins(.white): return "White wins!"
		case .none: return nil
		}
	}

	var hiveBorder: Set<Position> {
		Set(stacks
			.filter { $0.value.count > 0 }
			.flatMap { $0.key.adjacent() }
			.filter { (stacks[$0]?.count ?? 0) == 0}
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
		case .allowSpecialAbilityAfterYoink, .noFirstMoveQueen: return false
		}
	}

	var displayName: String {
		switch self {
		case .allowSpecialAbilityAfterYoink: return "Allow special ability after yoink"
		case .noFirstMoveQueen: return "Disable Queen on first move"
		case .ladyBug: return "Lady Bug"
		case .mosquito: return "Mosquito"
		case .pillBug: return "Pill Bug"
		}
	}
}

extension GameState.Option: Comparable {
	public static func < (lhs: GameState.Option, rhs: GameState.Option) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
}

// MARK: - Players

extension Player {
	var color: ColorAsset {
		switch self {
		case .white: return .white
		case .black: return .highlightPrimary
		}
	}

	var secondaryColor: ColorAsset {
		switch self {
		case .white: return .whiteTransparent
		case .black: return .highlightPrimaryTransparent
		}
	}
}
