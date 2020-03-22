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
	convenience init(from piece: Piece) {
		self.init(imageNamed: "Pieces/\(piece.class.description)")
		color = piece.owner == .white ? UIColor(.white) : UIColor(.primary)
		colorBlendFactor = 1
	}
}
