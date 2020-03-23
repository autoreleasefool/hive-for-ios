//
//  SKView+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SpriteKit

extension SKScene {
	@discardableResult
	func addUnownedChild(_ node: SKNode) -> Bool {
		guard node.parent == nil else { return false }
		addChild(node)
		return true
	}
}
