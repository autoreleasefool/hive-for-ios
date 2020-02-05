//
//  Experience+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-27.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import RealityKit
import HiveEngine

extension Experience.HiveGame {
	var allPieces: [Entity?] {
		return blackPieces + whitePieces
	}

	var blackPieces: [Entity?] {
		return [
			bA1,
			bA2,
			bA3,
			bB1,
			bB2,
			bG1,
			bG2,
			bG3,
			bL,
			bM,
			bP,
			bQ,
			bS1,
			bS2,
		]
	}

	var whitePieces: [Entity?] {
		return [
			wA1,
			wA2,
			wA3,
			wB1,
			wB2,
			wG1,
			wG2,
			wG3,
			wL,
			wM,
			wP,
			wQ,
			wS1,
			wS2,
		]
	}

	func pieces(for player: Player) -> [Entity?] {
		switch player {
		case .white: return whitePieces
		case .black: return blackPieces
		}
	}

	private func openPositionName(at index: Int) -> String {
		"OpenPosition-\(index)"
	}

	func updateSnappingPositions(_ snappingPositions: [SIMD3<Float>]) {
		guard let baseModel = openPosition else { return }

		snappingPositions.enumerated().forEach { (index, position) in
			if let entity = findEntity(named: openPositionName(at: index)) {
				entity.position = position
				entity.isEnabled = true
			} else {
				let cloned = baseModel.clone(recursive: true)
				cloned.name = openPositionName(at: index)
				addChild(cloned)
				cloned.position = position
				cloned.isEnabled = true
			}
		}
	}

	func removeSnappingPositions() {
		var index = 0
		while let entity = findEntity(named: openPositionName(at: index)) {
			entity.isEnabled = false
			index += 1
		}
	}
}

extension Entity {
	func visit(using block: (Entity) -> Void) {
		block(self)

		for child in children {
			child.visit(using: block)
		}
	}

	var gamePiece: Piece? {
		return Piece(notation: self.name)
	}
}

extension SIMD3 where Scalar == Float {
	func euclideanDistance(to other: SIMD3<Scalar>) -> Scalar {
		return sqrt(pow(self.x - other.x, 2) + pow(self.y - other.y, 2) + pow(self.z - other.z, 2))
	}
}
