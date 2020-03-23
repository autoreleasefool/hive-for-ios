//
//  DebugSprite.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-23.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SpriteKit

class DebugSprite: SKNode {
	var debugInfo: DebugInfo = DebugInfo(touchPosition: .cgPoint(.zero)) {
		didSet {
			touchLabel.text = debugInfo.touchPositionFormatted
			positionLabel.text = debugInfo.hivePositionFormatted
		}
	}

	private var touchLabel = SKLabelNode()
	private var positionLabel = SKLabelNode()

	override init() {
		super.init()

		touchLabel.fontSize = 12
		touchLabel.position = .zero
		touchLabel.horizontalAlignmentMode = .left
		addChild(touchLabel)

		positionLabel.fontSize = 12
		positionLabel.position = CGPoint(x: 0, y: 20)
		positionLabel.horizontalAlignmentMode = .left
		addChild(positionLabel)

		let background = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 200, height: 50))
		background.fillColor = UIColor(.backgroundLight)
		background.position = .zero
		addChild(background)

		self.position = CGPoint(x: 0, y: 500)
		self.alpha = 0.5
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
