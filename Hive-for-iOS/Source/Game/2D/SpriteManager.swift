//
//  SpriteManager.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-21.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SpriteKit
import HiveEngine

class SpriteManager {
	private var pieceSprites: [Piece: SKSpriteNode] = [:]
	private var pieceSpriteVisibility: [Piece: Bool] = [:]
	private var positionSprites: [Position: SKSpriteNode] = [:]

	var piecesWithSprites: [Piece] { Array(pieceSprites.keys) }
	var positionsWithSprites: [Position] { Array(positionSprites.keys) }

	func sprite(
		for piece: Piece,
		initialSize: CGSize,
		initialScale: CGPoint,
		initialOffset: CGPoint,
		blank: Bool = false
	) -> SKSpriteNode {
		if let sprite = pieceSprites[piece] {
			if blank && pieceSpriteVisibility[piece] == true {
				sprite.texture = SKTexture(imageNamed: "Pieces/Blank")
				pieceSpriteVisibility[piece] = false
			} else if !blank && pieceSpriteVisibility[piece] == false {
				sprite.texture = SKTexture(imageNamed: "Pieces/\(piece.class.description)")
				pieceSpriteVisibility[piece] = true
			}

			return sprite
		}

		let sprite = SKSpriteNode(from: piece)
		sprite.name = "Piece-\(piece.notation)"
		sprite.zPosition = 1
		sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		sprite.size = initialSize
		sprite.position = Position.origin.point(scale: initialScale, offset: initialOffset)

		pieceSprites[piece] = sprite
		pieceSpriteVisibility[piece] = blank
		return sprite
	}

	func piece(from sprite: SKNode) -> Piece? {
		guard let name = sprite.name else { return nil }
		let notation = name.starts(with: "Piece-") ? name.substring(from: 6) : ""
		return Piece(notation: notation)
	}

	func sprite(
		for position: Position,
		initialSize: CGSize,
		initialScale: CGPoint,
		initialOffset: CGPoint
	) -> SKSpriteNode {
		if let sprite = positionSprites[position] {
			return sprite
		}

		let sprite = SKSpriteNode(imageNamed: "Pieces/Blank")
		positionSprites[position] = sprite

		sprite.name = "Position-\(position.description)"
		sprite.size = initialSize
		sprite.position = position.point(scale: initialScale, offset: initialOffset)
		sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		resetColor(for: position)
		sprite.colorBlendFactor = 1
		sprite.zPosition = -1

		if debugEnabled {
			addPositionLabel(to: position)
		}

		return sprite
	}

	func resetColor(for position: Position) {
		let sprite = self.sprite(for: position, initialSize: .zero, initialScale: .zero, initialOffset: .zero)
		sprite.color = UIColor(.backgroundLight)
	}

	func highlight(_ piece: Piece) {
		let sprite = self.sprite(for: piece, initialSize: .zero, initialScale: .zero, initialOffset: .zero)
		sprite.color = UIColor(piece.owner.secondaryColor)
	}

	func resetColor(for piece: Piece) {
		let sprite = self.sprite(for: piece, initialSize: .zero, initialScale: .zero, initialOffset: .zero)
		sprite.color = UIColor(piece.owner.color)
	}

	var debugEnabled: Bool = false {
		didSet {
			positionSprites.keys.forEach {
				if debugEnabled {
					addPositionLabel(to: $0)
				} else {
					removePositionLabel(from: $0)
				}
			}
		}
	}
}

// MARK: - Debug

extension SpriteManager {
	private func addPositionLabel(to position: Position) {
		let sprite = self.sprite(for: position, initialSize: .zero, initialScale: .zero, initialOffset: .zero)
		guard sprite.childNode(withName: "Label") == nil else { return }
		let positionLabel = SKLabelNode(text: position.description)
		positionLabel.name = "Label"
		positionLabel.horizontalAlignmentMode = .center
		positionLabel.verticalAlignmentMode = .center
		positionLabel.fontSize = 12
		positionLabel.zPosition = 1
		sprite.addChild(positionLabel)
	}

	private func removePositionLabel(from position: Position) {
		let sprite = self.sprite(for: position, initialSize: .zero, initialScale: .zero, initialOffset: .zero)
		sprite.childNode(withName: "Label")?.removeFromParent()
	}
}
