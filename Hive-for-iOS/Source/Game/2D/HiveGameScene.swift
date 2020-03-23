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
	private let BASE_HEX_SCALE: CGPoint = CGPoint(x: 64, y: 64)
	private let BASE_HEX_SIZE: CGSize = CGSize(width: 123.5, height: 107.5)

	private let viewModel: HiveGameViewModel
	private var spriteManager = HiveSpriteManager()

	private var currentScaleMultiplier: CGFloat = 1 {
		didSet {
			updateSpritePositions()
		}
	}

	private var currentOffset: CGPoint = .zero {
		didSet {
			updateSpritePositions()
		}
	}

	private var currentScale: CGPoint {
		BASE_HEX_SCALE * currentScaleMultiplier
	}

	lazy var panGesture: UIPanGestureRecognizer = {
		let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
		gestureRecognizer.delegate = self
		return gestureRecognizer
	}()

	lazy var pinchGesture: UIPinchGestureRecognizer = {
		let gestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
		gestureRecognizer.delegate = self
		return gestureRecognizer
	}()

	init(viewModel: HiveGameViewModel, size: CGSize) {
		self.viewModel = viewModel
		super.init(size: size)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func sceneDidLoad() {
		subscribeToPublishers()
		viewModel.postViewAction(.viewContentDidLoad(.skScene(self)))
	}

	override func didMove(to view: SKView) {
		physicsWorld.gravity = .zero
		backgroundColor = UIColor(.backgroundDark)
		setupGestureRecognizers(in: view)

		viewModel.gameState.allPiecesInHands.forEach {
			resetPiece($0)
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
				self?.present(selectedPiece: receivedValue.0, at: receivedValue.1)
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
			sprite.position = $0.value.point(scale: currentScale, offset: currentOffset)
			addUnownedChild(sprite)
		}
	}

	private func present(selectedPiece piece: Piece?, at position: Position?) {
		viewModel.gameState.unitsInHand[viewModel.playingAs]?.forEach {
			guard $0 != piece else { return }
			resetPiece($0)
		}

		guard let piece = piece, let position = position else { return }

		let sprite = self.sprite(for: piece)
		sprite.position = position.point(scale: currentScale, offset: currentOffset)
		addUnownedChild(sprite)
	}

	func resetPiece(_ piece: Piece) {
		let sprite = self.sprite(for: piece)
		sprite.removeFromParent()
		sprite.position = Position.origin.point(scale: currentScale, offset: currentOffset)
	}

	private func resetGame() {
		viewModel.gameState.allPiecesInHands.forEach { resetPiece($0) }
	}

	private func updateSpritePositions() {
		spriteManager.pieceSprites.forEach {
			guard $0.value.parent != nil else { return }
			let position: Position
			if let gamePosition = viewModel.gameState.position(of: $0.key) {
				position = gamePosition
			} else if viewModel.selectedPiece.value.0 == $0.key,
				let selectedPosition = viewModel.selectedPiece.value.1 {
				position = selectedPosition
			} else {
				position = .origin
			}

			$0.value.position = position.point(scale: currentScale, offset: currentOffset)
			$0.value.size = BASE_HEX_SIZE * currentScaleMultiplier

		}

		spriteManager.positionSprites.forEach {
			guard $0.value.parent != nil else { return }
			$0.value.position = $0.key.point(scale: currentScale, offset: currentOffset)
			$0.value.size = BASE_HEX_SIZE * currentScaleMultiplier
		}
	}

	// MARK: - Touch

	private var currentNode: SKNode?
	private var snappingPositions: [CGPoint]?
	private var nodeInitialPosition: CGPoint?

	private func enableSnappingPositions(for piece: Piece) {
		let snappingPositions = Set(viewModel.gameState.availableMoves
			.filter { $0.movedUnit == piece }
			.compactMap { $0.targetPosition })
			.map { $0.point(scale: currentScale, offset: currentOffset) }

		snappingPositions.forEach {
			let sprite = self.sprite(for: $0.position())
			sprite.color = UIColor(.highlight)
			addUnownedChild(sprite)
		}

		self.snappingPositions = snappingPositions
	}

	private func removeSnappingPositions() {
		snappingPositions?.forEach {
			let position = $0.position(scale: currentScale, offset: currentOffset)
			let sprite = self.sprite(for: position)
			spriteManager.resetAppearance(sprite: sprite)
			if !viewModel.debugEnabledSubject.value {
				sprite.removeFromParent()
			}
		}

		snappingPositions = nil
	}

	private func snap(_ piece: Piece, location: CGPoint, move: Bool) {
		let position = location.position(scale: currentScale, offset: currentOffset)
		if move {
			viewModel.postViewAction(.gamePieceMoved(piece, position))
		} else {
			viewModel.postViewAction(.gamePieceSnapped(piece, position))
		}
	}

	var maxZPosition: CGFloat {
		self.children.map { $0.zPosition }.sorted().last ?? 0
	}
}

// MARK: - Gesture Recognizers

extension HiveGameScene: UIGestureRecognizerDelegate {
	private func setupGestureRecognizers(in view: SKView) {
		view.addGestureRecognizer(panGesture)
		view.addGestureRecognizer(pinchGesture)
	}

	@objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
		let intermediateTranslation = gesture.translation(in: self.view)
		let translation = CGPoint(x: intermediateTranslation.x, y: -intermediateTranslation.y)

		let intermediateTouch = gesture.location(in: self.view)
		let touchPoint = convertPoint(fromView: intermediateTouch)

		guard let touchedNode = currentNode ?? nodes(at: touchPoint)
				.first(where: { $0.name?.starts(with: "Piece-") == true}),
			let touchedPiece = spriteManager.piece(from: touchedNode) else {
			if gesture.state == .changed {
				panScreen(translation: translation)
				gesture.setTranslation(.zero, in: self.view)
			}
			return
		}

		if gesture.state == .began {
			touchedNode.zPosition = maxZPosition + 1
			nodeInitialPosition = touchedNode.position
			self.enableSnappingPositions(for: touchedPiece)
			self.currentNode = touchedNode
		} else if gesture.state == .changed {
			let translatedPosition = (nodeInitialPosition ?? touchedNode.position) + translation
			snap(touchedPiece, location: translatedPosition, move: false)
		} else if gesture.state == .ended {
			let translatedPosition = (nodeInitialPosition ?? touchedNode.position) + translation
			snap(touchedPiece, location: translatedPosition, move: true)
			self.currentNode = nil
			self.snappingPositions = nil
			self.nodeInitialPosition = nil
		}
	}

	@objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
		if gesture.state == .changed {
			currentScaleMultiplier = gesture.scale
		}
	}

	private func panScreen(translation: CGPoint) {
		currentOffset += translation
	}

	func gestureRecognizer(
		_ gestureRecognizer: UIGestureRecognizer,
		shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
	) -> Bool {
		true
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
					addUnownedChild(sprite)
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
