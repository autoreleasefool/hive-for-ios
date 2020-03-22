//
//  HiveGameScene.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-21.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SpriteKit
import HiveEngine

class HiveGameScene: SKScene {
	private let viewModel: HiveGameViewModel
	private var spriteManager = HiveSpriteManager()

	init(viewModel: HiveGameViewModel, size: CGSize) {
		self.viewModel = viewModel
		super.init(size: size)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func sceneDidLoad() {
		subscribeToPublishers()
	}

	override func didMove(to view: SKView) {
		physicsWorld.gravity = .zero
		backgroundColor = UIColor(.backgroundDark)

		viewModel.gameState.allPiecesInHands.forEach {
			resetPiece($0)
			addChild(sprite(for: $0))
		}

		viewModel.postViewAction(.viewInteractionsReady)
	}

	private func subscribeToPublishers() {
		viewModel.flowStateSubject
			.sink { [weak self] receivedValue in
				self?.handleTransition(to: receivedValue)
			}
			.store(in: viewModel)

		viewModel.gameStateSubject
			.sink { [weak self] receivedValue in
				guard let gameState = receivedValue else { return }
				self?.present(gameState: gameState)
			}
			.store(in: viewModel)

		viewModel.selectedPiece
			.sink { [weak self] receivedValue in
				self?.present(selectedPiece: receivedValue)
			}
			.store(in: viewModel)

		viewModel.debugEnabledSubject
			.sink { [weak self] receivedValue in
				self?.debugEnabled = receivedValue
			}
			.store(in: viewModel)
	}

	private func present(gameState: GameState) {
		// Hide pieces not in play
		viewModel.gameState.allPiecesInHands.forEach { resetPiece($0) }

		// Set position for pieces in play
		viewModel.gameState.allUnitsInPlay.forEach {
			let sprite = self.sprite(for: $0.key)
			sprite.position = $0.value.point()
			addChild(sprite)
		}
	}

	private func present(selectedPiece pieceClass: Piece.Class?) {
		viewModel.gameState.unitsInHand[viewModel.playingAs]?.forEach {
			resetPiece($0)
		}

		guard let pieceClass = pieceClass else { return }

		let pieces = Array(viewModel.gameState.playableUnits(for: viewModel.playingAs)).sorted()
		if let piece = pieces.first(where: { $0.class == pieceClass }) {
			let sprite = self.sprite(for: piece)
			sprite.position = Position.origin.point()
			if sprite.parent == nil {
				addChild(sprite)
			}
		}
	}

	func resetPiece(_ piece: Piece) {
		let sprite = self.sprite(for: piece)
		sprite.removeFromParent()
		sprite.position = Position.origin.point()
	}

	private func resetGame() {
		viewModel.gameState.allPiecesInHands.forEach { resetPiece($0) }
	}

	// MARK: - Touch

	private var currentNode: SKNode?
	private var snappingPositions: [CGPoint]?

	private func enableSnappingPositions(for piece: Piece) {
		let snappingPositions = Set(viewModel.gameState.availableMoves
			.filter { $0.movedUnit == piece }
			.compactMap { $0.targetPosition })
			.map { $0.point() }

		snappingPositions.forEach {
			let sprite = self.sprite(for: $0.position())
			sprite.color = UIColor(.highlight)
			if sprite.parent == nil {
				addChild(sprite)
			}
		}

		self.snappingPositions = snappingPositions
	}

	private func removeSnappingPositions() {
		snappingPositions?.forEach {
			let position = $0.position()
			let sprite = self.sprite(for: position)
			spriteManager.resetAppearance(sprite: sprite)
			if !viewModel.debugEnabledSubject.value {
				sprite.removeFromParent()
			}
		}

		snappingPositions = nil
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first,
			let touchedNode = nodes(at: touch.location(in: self))
				.first(where: { $0.name?.starts(with: "Piece-") == true }),
			let touchedPiece = spriteManager.piece(from: touchedNode) else { return }

		touchedNode.zPosition = maxZPosition + 1
		self.enableSnappingPositions(for: touchedPiece)
		self.currentNode = touchedNode
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first,
			let currentNode = self.currentNode else { return }
		snap(currentNode, location: touch.location(in: self))
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first,
			let currentNode = self.currentNode,
			let currentPiece = spriteManager.piece(from: currentNode) else { return }
		snap(currentNode, location: touch.location(in: self))
		self.currentNode = nil
		self.snappingPositions = nil
		viewModel.postViewAction(.gamePieceMoved(currentPiece, currentNode.position.position()))
	}

	private func snap(_ node: SKNode, location: CGPoint) {
		if let snappingPositions = snappingPositions, let firstPosition = snappingPositions.first {
			let initialClosest = (location.euclideanDistance(to: firstPosition), firstPosition)
			let closest = snappingPositions.reduce(initialClosest) { (previous, snappingPosition) in
				let distance = location.euclideanDistance(to: snappingPosition)
				return distance < previous.0 ? (distance, snappingPosition) : previous
			}

			if closest.0 < 128 {
				node.position = closest.1
				return
			}
		}

		node.position = location
	}

	var maxZPosition: CGFloat {
		self.children.map { $0.zPosition }.sorted().last ?? 0
	}
}

// MARK: - HiveGameViewModel.State

extension HiveGameScene {
	private func handleTransition(to newState: HiveGameViewModel.State) {
		switch newState {
		case .gameStart:
			prepareGame()
		case .begin, .gameEnd, .forfeit, .opponentTurn, .sendingMovement, .receivingMovement:
			#warning("TODO: handle remaining state changes in view")
		case .playerTurn:
			startPlayerTurn()
		}
	}

	private func prepareGame() {
		resetGame()
		enablePositionGrid(debugEnabled)
		viewModel.postViewAction(.viewContentReady)
	}

	private func startPlayerTurn() {

	}
}

// MARK: - Sprites

extension HiveGameScene {
	private func sprite(for piece: Piece) -> SKSpriteNode {
		spriteManager.sprite(for: piece)
	}

	private func sprite(for position: Position) -> SKSpriteNode {
		spriteManager.sprite(for: position)
	}
}

// MARK: - Debug

extension HiveGameScene {
	private func enablePositionGrid(_ enabled: Bool) {
		for x in -4...4 {
			for z in -4...4 {
				let position = Position(x: x, y: -z - x, z: z)
				let sprite = self.sprite(for: position)

				if enabled {
					addChild(sprite)
					spriteManager.hidePositionLabel(for: position, hidden: false)
				} else {
					sprite.removeFromParent()
					spriteManager.hidePositionLabel(for: position, hidden: true)
				}
			}
		}
	}

	private var debugEnabled: Bool {
		get {
			viewModel.debugEnabledSubject.value
		}
		set {
			DispatchQueue.main.async {
				self.enablePositionGrid(newValue)
			}
		}
	}
}
