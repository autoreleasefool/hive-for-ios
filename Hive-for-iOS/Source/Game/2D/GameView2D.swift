//
//  GameView2D.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-21.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SpriteKit
import HiveEngine

class GameView2D: SKScene {
	private let BASE_HEX_SCALE: CGPoint = CGPoint(x: 64, y: 64)
	private let BASE_HEX_SIZE: CGSize = CGSize(width: 109, height: 95)

	private let viewModel: GameViewModel
	private var playerViewModel: PlayerGameViewModel? {
		viewModel as? PlayerGameViewModel
	}

	private var debugSprite = DebugSprite()
	private var spriteManager = SpriteManager()

	private var piecesInPlay: [Piece] { spriteManager.piecesWithSprites }
	private var positionsInPlay: [Position] { spriteManager.positionsWithSprites }

	private var currentScaleMultiplier: CGFloat = 0.75 {
		didSet {
			if currentScaleMultiplier < 0.25 {
				currentScaleMultiplier = 0.26
			} else if currentScaleMultiplier > 2 {
				currentScaleMultiplier = 1.99
			}
			updateSpriteScaleAndOffset()
		}
	}

	private var currentOffset: CGPoint = .zero {
		didSet {
			updateSpriteScaleAndOffset()
		}
	}

	private var currentScale: CGPoint {
		BASE_HEX_SCALE * currentScaleMultiplier
	}

	private var currentHexSize: CGSize {
		BASE_HEX_SIZE * currentScaleMultiplier
	}

	lazy var tapGesture: UITapGestureRecognizer = {
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		gestureRecognizer.delegate = self
		return gestureRecognizer
	}()

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

	init(viewModel: GameViewModel, size: CGSize) {
		self.viewModel = viewModel
		super.init(size: size)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Initial Load

	private var hasMovedToView = false
	private var hasChangedSize = false

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

		hasMovedToView = true
		if hasChangedSize {
			viewModel.postViewAction(.viewInteractionsReady)
		}
	}

	override func didChangeSize(_ oldSize: CGSize) {
		guard !viewModel.inGame, size.equalTo(.zero) == false else { return }
		currentOffset = CGPoint(x: size.width / 2, y: size.height / 2)

		hasChangedSize = true
		if hasMovedToView {
			viewModel.postViewAction(.viewInteractionsReady)
		}
	}

	private func subscribeToPublishers() {
		playerViewModel?.$state
			.sink { [weak self] in
				self?.handleTransition(to: $0)
			}
			.store(in: viewModel)

		viewModel.$gameState
			.sink { [weak self] in
				self?.present(gameState: $0)
			}
			.store(in: viewModel)

		viewModel.$selectedPiece
			.sink { [weak self] in
				self?.present(deselectedPiece: $0.deselected, selectedPiece: $0.selected)
			}
			.store(in: viewModel)

		viewModel.$debugMode
			.sink { [weak self] enabled in
				self?.spriteManager.debugEnabled = enabled
				DispatchQueue.main.async {
					guard let self = self else { return }
					if enabled {
						self.addUnownedChild(self.debugSprite)
					} else {
						self.debugSprite.removeFromParent()
					}
				}
			}
			.store(in: viewModel)

		viewModel.animateToPosition
			.sink { [weak self] in
				self?.animate(to: $0)
			}
			.store(in: viewModel)
	}

	private func present(gameState: GameState) {
		// Hide pieces not in play
		viewModel.gameState.allPiecesInHands.forEach { resetPiece($0) }

		// Set position for pieces in play
		viewModel.gameState.unitsInPlay.forEach { (_, units) in
			units.forEach {
				let sprite = self.sprite(for: $0.key)
				sprite.position = $0.value.point(scale: currentScale, offset: currentOffset)
				addUnownedChild(sprite)
			}
		}

		// Show border of the field
		viewModel.gameState.hiveBorder.forEach {
			let sprite = self.sprite(for: $0)
			addUnownedChild(sprite)
		}

		// Ensure the origin is always visible
		addUnownedChild(self.sprite(for: .origin))

		updateSpriteScaleAndOffset()
		updateSpriteAlpha()
	}

	private func present(
		deselectedPiece: GameViewModel.SelectedPiece?,
		selectedPiece: GameViewModel.SelectedPiece?
	) {
		if let viewModel = playerViewModel {
			viewModel.gameState.unitsInHand[viewModel.playingAs]?.forEach {
				guard $0 != selectedPiece?.piece else { return }
				resetPiece($0)
			}
		}

		if let deselected = deselectedPiece, positionsInPlay.contains(deselected.position) {
			addUnownedChild(self.sprite(for: deselected.position))
		}

		guard let piece = selectedPiece?.piece, let position = selectedPiece?.position else { return }

		let sprite = self.sprite(for: piece)
		sprite.position = position.point(scale: currentScale, offset: currentOffset)
		addUnownedChild(sprite)
		updateSpriteScaleAndOffset()
		updateSpriteAlpha()

		if positionsInPlay.contains(position) {
			self.sprite(for: position).removeFromParent()
		}
	}

	func resetPiece(_ piece: Piece) {
		let sprite = self.sprite(for: piece)
		sprite.removeFromParent()
		sprite.position = Position.origin.point(scale: currentScale, offset: currentOffset)
	}

	private func resetGame() {
		viewModel.gameState.allPiecesInHands.forEach { resetPiece($0) }
	}

	private static let bottomStackOffset: CGFloat = -8.0
	private static let topStackOffset: CGFloat = 16.0

	private func updateSpriteScaleAndOffset() {
		piecesInPlay.forEach { piece in
			let sprite = self.sprite(for: piece)

			// Get position to snap sprite to
			guard sprite.parent != nil else { return }
			let position = viewModel.position(of: piece)

			// Set current position and size of sprite based on scale and global offset
			sprite.position = position.point(scale: currentScale, offset: currentOffset)
			sprite.size = currentHexSize

			// Check if the piece is part of a stack and, if so, offset it based on its position in the stack
			let (positionInStack, stackCount) = viewModel.positionInStack(of: piece)
			if stackCount > 1 {
				let incrementor = GameView2D.topStackOffset / CGFloat(stackCount - 1)
				sprite.position.x += (GameView2D.bottomStackOffset + incrementor * CGFloat(positionInStack - 1))
					* currentScaleMultiplier
			}
		}

		positionsInPlay.forEach { position in
			let sprite = self.sprite(for: position)
			guard sprite.parent != nil else { return }
			sprite.position = position.point(scale: currentScale, offset: currentOffset)
			sprite.size = currentHexSize
		}

		self.debugSprite.debugInfo.update(
			scale: currentScale,
			offset: currentOffset
		)
	}

	private func updateSpriteAlpha() {
		piecesInPlay.forEach { piece in
			let sprite = self.sprite(for: piece)
			let (positionInStack, stackCount) = viewModel.positionInStack(of: piece)
			sprite.alpha = positionInStack < stackCount ? CGFloat(positionInStack) / CGFloat(stackCount) : 1
		}
	}

	// MARK: - Touch

	private var nodeBeingMoved: SKNode?
	private var nodeInitialPosition: CGPoint?
	private var snappingPositions: [CGPoint]?

	private func enableSnappingPositions(for piece: Piece) {
		let snappingPositions = Set(viewModel.gameState.availableMoves
			.filter { $0.movedUnit == piece }
			.compactMap { $0.targetPosition })
			.map { $0.point(scale: currentScale, offset: currentOffset) }

		snappingPositions.forEach {
			let sprite = self.sprite(for: $0.position(scale: currentScale, offset: currentOffset))
			sprite.color = UIColor(.highlightRegular)
			sprite.zPosition = maxPieceZPosition - 0.05
			addUnownedChild(sprite)
			updateSpriteScaleAndOffset()
		}

		self.snappingPositions = snappingPositions
	}

	private func removeSnappingPositions() {
		snappingPositions?.forEach {
			let position = $0.position(scale: currentScale, offset: currentOffset)
			spriteManager.resetColor(for: position)

			let sprite = self.sprite(for: position)
			sprite.zPosition = -1
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

	var maxPieceZPosition: CGFloat {
		piecesInPlay.map { sprite(for: $0).zPosition }.sorted().last ?? 0
	}
}

// MARK: - Gesture Recognizers

extension GameView2D: UIGestureRecognizerDelegate {
	private func setupGestureRecognizers(in view: SKView) {
		view.addGestureRecognizer(tapGesture)
		view.addGestureRecognizer(panGesture)
		view.addGestureRecognizer(pinchGesture)
	}

	@objc private func handleTap(_ gesture: UITapGestureRecognizer) {
		removeAction(forKey: AnimationKey.toPosition.rawValue)

		let intermediateTouch = gesture.location(in: self.view)
		let touchPoint = convertPoint(fromView: intermediateTouch)

		for node in nodes(at: touchPoint) where spriteManager.piece(from: node) != nil {
			guard let piece = spriteManager.piece(from: node) else { continue }
			viewModel.postViewAction(.tappedGamePiece(piece))
			return
		}
	}

	@objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
		removeAction(forKey: AnimationKey.toPosition.rawValue)

		let intermediateTranslation = gesture.translation(in: self.view)
		let translation = CGPoint(x: intermediateTranslation.x, y: -intermediateTranslation.y)

		let intermediateTouch = gesture.location(in: self.view)
		let touchPoint = convertPoint(fromView: intermediateTouch)

		if gesture.state == .began, playerViewModel?.state == .playerTurn {
			nodeBeingMoved = nodes(at: touchPoint).first(where: {
				guard let piece = spriteManager.piece(from: $0) else { return false }
				return viewModel.gameState.pieceHasMoves(piece)
			})
		}

		guard let touchedNode = nodeBeingMoved,
			let touchedPiece = spriteManager.piece(from: touchedNode) else {
			if gesture.state == .changed {
				panScreen(translation: translation)
				gesture.setTranslation(.zero, in: self.view)

				self.debugSprite.debugInfo.update(
					touchPosition: .cgPoint(touchPoint),
					position: touchPoint.position(scale: currentScale, offset: currentOffset)
				)
			}
			return
		}

		self.debugSprite.debugInfo.update(
			touchPosition: .cgPoint(touchPoint),
			position: touchPoint.position(scale: currentScale, offset: currentOffset)
		)

		if gesture.state == .began {
			touchedNode.zPosition = maxPieceZPosition + 0.1
			nodeInitialPosition = touchPoint
			let translatedPosition = (nodeInitialPosition ?? touchedNode.position) + translation
			self.enableSnappingPositions(for: touchedPiece)
			snap(touchedPiece, location: translatedPosition, move: false)
		} else if gesture.state == .changed {
			let translatedPosition = (nodeInitialPosition ?? touchedNode.position) + translation
			snap(touchedPiece, location: translatedPosition, move: false)
		} else if gesture.state == .ended {
			let translatedPosition = (nodeInitialPosition ?? touchedNode.position) + translation
			snap(touchedPiece, location: translatedPosition, move: true)
			removeSnappingPositions()
			self.nodeBeingMoved = nil
			self.snappingPositions = nil
			self.nodeInitialPosition = nil
		}
	}

	@objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
		if nodeBeingMoved != nil {
			removeSnappingPositions()
			nodeBeingMoved = nil
			snappingPositions = nil
			nodeInitialPosition = nil
			updateSpriteScaleAndOffset()
		}

		if gesture.state == .changed {
			currentScaleMultiplier *= gesture.scale
			gesture.scale = 1
		}
	}

	private func panScreen(translation: CGPoint) {
		currentOffset += translation

		if positionsInPlay.contains(where: { piece in
			let sprite = self.sprite(for: piece)
			return sprite.parent != nil && frame.contains(sprite.position)
		}) {
			guard viewModel.isOutOfBounds else { return }
			viewModel.postViewAction(.hasMovedInBounds)
		} else {
			guard !viewModel.isOutOfBounds else { return }
			viewModel.postViewAction(.hasMovedOutOfBounds)
		}
	}

	func gestureRecognizer(
		_ gestureRecognizer: UIGestureRecognizer,
		shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
	) -> Bool {
		gestureRecognizer is UITapGestureRecognizer == false &&
			otherGestureRecognizer is UITapGestureRecognizer == false
	}
}

// MARK: - GameViewModel.State

extension GameView2D {
	private func handleTransition(to newState: PlayerGameViewModel.State) {
		switch newState {
		case .gameStart:
			prepareGame()
		case .playerTurn, .opponentTurn:
			resetForPlayerTurn()
		case .begin, .gameEnd, .forfeit, .sendingMovement, .shutDown:
			break
		}
	}

	private func prepareGame() {
		resetGame()
		viewModel.postViewAction(.viewContentReady)
	}

	private func resetForPlayerTurn() {
		present(gameState: viewModel.gameState)
	}
}

// MARK: - Sprites

extension GameView2D {
	private func sprite(for piece: Piece) -> SKSpriteNode {
		let (positionInStack, stackCount) = viewModel.positionInStack(of: piece)

		return spriteManager.sprite(
			for: piece,
			initialSize: currentHexSize,
			initialScale: currentScale,
			initialOffset: currentOffset,
			blank: positionInStack < stackCount
		)
	}

	private func sprite(for position: Position) -> SKSpriteNode {
		spriteManager.sprite(
			for: position,
			initialSize: currentHexSize,
			initialScale: currentScale,
			initialOffset: currentOffset
		)
	}
}

// MARK: - Animation

extension GameView2D {
	enum AnimationKey: String {
		case toPosition
	}

	private func animate(to piece: Piece) {
		guard let position = viewModel.gameState.position(of: piece) else { return }
		animate(to: position)
	}

	private func animate(to position: Position) {
		self.removeAction(forKey: AnimationKey.toPosition.rawValue)

		let startingOffset = currentOffset
		let offsetDifference = position.point(scale: currentScale, offset: currentOffset) -
			CGPoint(x: size.width / 2, y: size.height / 2)
		let duration: TimeInterval = 0.5

		let action = SKAction.customAction(withDuration: duration) { [weak self] _, elapsed in
			let percentElapsed = elapsed / CGFloat(duration)
			self?.currentOffset = startingOffset - (offsetDifference * percentElapsed)
		}
		action.timingMode = .easeInEaseOut

		self.run(action, withKey: AnimationKey.toPosition.rawValue)
	}
}
