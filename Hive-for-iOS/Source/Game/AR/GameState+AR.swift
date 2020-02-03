//
//  GameState+AR.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-02-02.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import RealityKit
import HiveEngine

//       Hexagonal grid system
//                _____
//          +y   /     \   -z
//              /       \
//        ,----(  0,1,-1 )----.
//       /      \       /      \
//      /        \_____/        \
//      \ -1,1,0 /     \ 1,0,-1 /
//       \      /       \      /
//  -x    )----(  0,0,0  )----(    +x
//       /      \       /      \
//      /        \_____/        \
//      \ -1,0,1 /     \ 1,-1,0 /
//       \      /       \      /
//        `----(  0,-1,1 )----'
//              \       /
//          +z   \_____/   -y
//

extension Position {
	fileprivate static let horizontalScale: Float = 0.05
	fileprivate static let verticalScale: Float = 0.02

	var vector: SIMD3<Float> {
		let q = Float(x)
		let r = Float(z)
		let x: Float = Position.horizontalScale * (Float(3.0 / 2.0) * q)
		let z: Float = Position.horizontalScale * (sqrt(Float(3.0)) / 2.0 * q + sqrt(Float(3.0)) * r)
		return SIMD3(x: x, y: 0, z: z)
	}
}

extension SIMD3 where Scalar == Float {
	var position: Position {
		let xToQ: Float = 2.0 / 3.0 * self.x
		let q = Int((xToQ / Position.horizontalScale).rounded())

		let xToR: Float = 1.0 / 3.0 * self.x
		let yToR: Float = sqrt(Float(3.0)) / 3.0 * self.y
		let r = Int(((xToR + yToR) / Position.horizontalScale).rounded())

		return Position(x: q, y: -r - q, z: r)
	}
}

extension Piece {
	func entity(in game: Experience.HiveGame) -> Entity? {
		game.findEntity(named: self.notation)
	}
}
