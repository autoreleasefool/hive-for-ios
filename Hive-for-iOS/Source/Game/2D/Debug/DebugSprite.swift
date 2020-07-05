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
			touchIndicator.position = debugInfo.touchPosition.point
			positionIndicator.position = debugInfo.hivePosition.point(scale: debugInfo.scale, offset: debugInfo.offset)
		}
	}

	private var touchLabel = SKLabelNode()
	private var positionLabel = SKLabelNode()

	private var touchIndicator = SKShapeNode(rectOf: CGSize(width: 5, height: 5))
	private var positionIndicator = SKShapeNode(rectOf: CGSize(width: 5, height: 5))

	override init() {
		super.init()

		let background = SKShapeNode(rectOf: CGSize(width: 200, height: 50))
		background.fillColor = UIColor(.backgroundLight)
		background.position = CGPoint(x: 100, y: 200)
		addChild(background)

		touchLabel.fontSize = 12
		touchLabel.position = .zero
		touchLabel.horizontalAlignmentMode = .left
		background.addChild(touchLabel)

		positionLabel.fontSize = 12
		positionLabel.position = CGPoint(x: 0, y: 20)
		positionLabel.horizontalAlignmentMode = .left
		background.addChild(positionLabel)

		touchIndicator.fillColor = UIColor(.primary)
		addChild(touchIndicator)

		positionIndicator.fillColor = UIColor(.highlight)
		addChild(positionIndicator)

		self.alpha = 0.5
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
