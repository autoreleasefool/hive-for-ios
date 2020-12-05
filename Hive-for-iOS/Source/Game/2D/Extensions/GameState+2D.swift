//
//  GameState+2D.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-21.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SpriteKit
import HiveEngine

extension SKSpriteNode {
	convenience init(from piece: Piece, colorScheme: Preferences.PieceColorScheme) {
		let path: String
		switch colorScheme {
		case .outlined: path = ""
		case .filled: path = "Filled/"
		}
		self.init(imageNamed: "Pieces/\(piece.owner)/\(path)\(piece.class.description)")
	}
}

extension SKTexture {
	convenience init(from piece: Piece, colorScheme: Preferences.PieceColorScheme) {
		let path: String
		switch colorScheme {
		case .outlined: path = ""
		case .filled: path = "Filled/"
		}
		self.init(imageNamed: "Pieces/\(piece.owner)/\(path)\(piece.class.description)")
	}
}

extension Position {
	func point(scale: CGPoint, offset: CGPoint) -> CGPoint {
		let q = CGFloat(x)
		let r = CGFloat(z)
		let x: CGFloat = CGFloat(3.0 / 2.0) * q
		let y: CGFloat = sqrt(CGFloat(3.0)) / 2.0 * q + sqrt(CGFloat(3.0)) * r
		return CGPoint(x: offset.x + scale.x * x, y: offset.y + scale.y * y)
	}

	func distance(to: Position) -> CGFloat {
		let point = self.point(scale: CGPoint(x: 1, y: 1), offset: .zero)
		let otherPoint = to.point(scale: CGPoint(x: 1, y: 1), offset: .zero)
		return point.euclideanDistance(to: otherPoint)
	}
}

extension CGPoint {
	func position(scale: CGPoint, offset: CGPoint) -> Position {
		let x = self.x - offset.x
		let y = self.y - offset.y
		let qf = (2 * x) / (3 * scale.x)
		let rf = (y / (sqrt(CGFloat(3.0)) * scale.y)) - (qf / 2)

		let q = Int(qf.rounded())
		let r = Int(rf.rounded())

		return Position(x: q, y: -r - q, z: r)
	}

	func euclideanDistance(to other: CGPoint) -> CGFloat {
		sqrt(pow(self.x - other.x, 2) + pow(self.y - other.y, 2))
	}
}
