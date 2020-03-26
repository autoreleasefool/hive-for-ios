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
	private let BASE_HEX_SIZE: CGSize = CGSize(width: 109, height: 95)

	private let viewModel: HiveGameViewModel
	private var spriteManager = HiveSpriteManager()

	private var debugSprite = DebugSprite()

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
		guard !viewModel.flowStateSubject.value.inGame, size.equalTo(.zero) == false else { return }
		currentOffset = CGPoint(x: size.width / 2, y: size.height / 2)

		hasChangedSize = true
		if hasMovedToView {
			viewModel.postViewAction(.viewInteractionsReady)
		}
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

		viewModel.animateToPosition
			.sink { [weak self] receivedValue in
				self?.animate(to: receivedValue)
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
			spriteManager.resetAppearance(sprite: sprite, gameState: gameState)
			addUnownedChild(sprite)
			updateSpriteScaleAndOffset()
		}

		viewModel.gameState.playableSpaces().forEach {
			let sprite = self.sprite(for: $0)
			sprite.color = UIColor(.backgroundLight)
			addUnownedChild(sprite)
			updateSpriteScaleAndOffset()
		}
	}

	private func present(selectedPiece: HiveGameViewModel.SelectedPiece?) {
		viewModel.gameState.unitsInHand[viewModel.playingAs]?.forEach {
			guard $0 != selectedPiece?.piece else { return }
			resetPiece($0)
		}

		guard let piece = selectedPiece?.piece, let position = selectedPiece?.position else { return }

		let sprite = self.sprite(for: piece)
		sprite.position = position.point(scale: currentScale, offset: currentOffset)
		addUnownedChild(sprite)
		updateSpriteScaleAndOffset()

		if let position = viewModel.gameState.position(of: piece), let stack = viewModel.gameState.stacks[position] {
			stack.forEach {
				let sprite = self.sprite(for: $0)
				spriteManager.resetAppearance(sprite: sprite, gameState: viewModel.gameState)
			}
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

	private func updateSpriteScaleAndOffset() {
		spriteManager.pieceSprites.forEach {
			guard $0.value.parent != nil else { return }
			let position: Position
			if viewModel.selectedPiece.value?.piece == $0.key,
				let selectedPosition = viewModel.selectedPiece.value?.position {
				position = selectedPosition
			} else if let gamePosition = viewModel.gameState.position(of: $0.key) {
				position = gamePosition
			} else {
				position = .origin
			}

			$0.value.position = position.point(scale: currentScale, offset: currentOffset)
			$0.value.size = currentHexSize

			if let stack = viewModel.gameState.stacks[position],
				stack.count > 1,
				let index = stack.firstIndex(of: $0.key) {
				let cgIndex = CGFloat(index)
				let incrementor: CGFloat = 16.0 / CGFloat(stack.count - 1)
				$0.value.position.x += (-8.0 + incrementor * cgIndex) * currentScaleMultiplier
			}
		}

		spriteManager.positionSprites.forEach {
			guard $0.value.parent != nil else { return }
			$0.value.position = $0.key.point(scale: currentScale, offset: currentOffset)
			$0.value.size = currentHexSize
		}

		self.debugSprite.debugInfo.update(
			scale: currentScale,
			offset: currentOffset
		)
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
			sprite.color = UIColor(.highlight)
			addUnownedChild(sprite)
			updateSpriteScaleAndOffset()
		}

		self.snappingPositions = snappingPositions
	}

	private func removeSnappingPositions() {
		snappingPositions?.forEach {
			let position = $0.position(scale: currentScale, offset: currentOffset)
			spriteManager.resetColor(for: position)
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
		removeAction(forKey: AnimationKey.toPosition.rawValue)

		let intermediateTranslation = gesture.translation(in: self.view)
		let translation = CGPoint(x: intermediateTranslation.x, y: -intermediateTranslation.y)

		let intermediateTouch = gesture.location(in: self.view)
		let touchPoint = convertPoint(fromView: intermediateTouch)

		if gesture.state == .began {
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
			touchedNode.zPosition = maxZPosition + 1
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
		if gesture.state == .changed {
			currentScaleMultiplier *= gesture.scale
			gesture.scale = 1
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
		spriteManager.sprite(
			for: piece,
			initialSize: currentHexSize,
			initialScale: currentScale,
			initialOffset: currentOffset,
			blank: !((viewModel.gameState.unitIsTopOfStack[piece] ?? true) ||
				viewModel.gameState.position(of: piece) == nil)
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
					if !viewModel.gameState.playableSpaces().contains(position) {
						sprite.removeFromParent()
					}
					spriteManager.hidePositionLabel(for: position, hidden: true)
				}
			}
		}

		updateSpriteScaleAndOffset()
	}

	private var debugEnabled: Bool {
		get {
			viewModel.debugEnabledSubject.value
		}
		set {
			DispatchQueue.main.async {
				self.enablePositionGrid(newValue)
				if newValue {
					self.addUnownedChild(self.debugSprite)
				} else {
					self.debugSprite.removeFromParent()
				}
			}
		}
	}
}

// MARK: - Animation

extension HiveGameScene {
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
