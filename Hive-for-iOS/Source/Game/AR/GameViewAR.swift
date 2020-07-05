//
//  GameViewAR.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine
import RealityKit
import ARKit
import HiveEngine
import Loaf

#if targetEnvironment(simulator)

class GameViewAR: UIView { }

#else

class GameViewAR: UIView {

	private var viewModel: GameViewModel

	private var arView = ARView(frame: .zero)

	private let debugOverlay = DebugOverlay(enabled: true)

	init(viewModel: GameViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func didMoveToSuperview() {
		super.didMoveToSuperview()

		addSubview(arView)
		arView.constrainToFillView(self)
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapArView))
		arView.addGestureRecognizer(tapGesture)

		addSubviewForAutoLayout(debugOverlay)
		NSLayoutConstraint.activate([
			debugOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
			debugOverlay.topAnchor.constraint(equalTo: topAnchor),
		])

		subscribeToPublishers()
		setupExperience()
		becomeFirstResponder()
	}

	private func subscribeToPublishers() {
		viewModel.stateStore
			.sink { [weak self] in
				self?.handleTransition(to: $0)
			}
			.store(in: viewModel)

		viewModel.gameStateStore
			.sink { [weak self] in
				self?.present(gameState: $0)
			}
			.store(in: viewModel)

		viewModel.selectedPiece
			.sink { [weak self] in
				self?.present(deselectedPiece: $0.0, selectedPiece: $0.1)
			}
			.store(in: viewModel)

		viewModel.debugModeStore
			.assign(to: \.debugEnabled, on: self)
			.store(in: viewModel)
	}

	private func setupExperience() {
		arView.automaticallyConfigureSession = false

		let arConfiguration = ARWorldTrackingConfiguration()
		arConfiguration.isCollaborationEnabled = false
		arConfiguration.planeDetection = .horizontal

		arView.session.delegate = self
		arView.session.run(arConfiguration, options: [])

		enableCoaching()

		Experience.loadHiveGameAsync { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let hiveGame):
				self.viewModel.postViewAction(.viewContentDidLoad(.arExperience(hiveGame)))
			case .failure(let error):
				self.viewModel.postViewAction(.arViewError(error))
			}
		}
	}

	private func enableCoaching() {
		let coachingOverlay = ARCoachingOverlayView()
		coachingOverlay.delegate = self
		coachingOverlay.session = arView.session
		coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		coachingOverlay.goal = .horizontalPlane
		arView.addSubview(coachingOverlay)
	}

	@objc private func didTapArView(_ sender: UITapGestureRecognizer) {
		guard viewModel.inGame else { return }
		let location = sender.location(in: arView)
		guard let tappedPiece = arView.entity(at: location),
			let gamePiece = tappedPiece.gamePiece else {
			return
		}

		viewModel.postViewAction(.tappedPiece(gamePiece))
	}

	private func present(gameState: GameState) {
		guard let game = viewModel.gameAnchor else { return }

		// Hide pieces not in play
		viewModel.gameState.unitsInHand[.white]?.forEach { $0.entity(in: game)?.isEnabled = false }
		viewModel.gameState.unitsInHand[.black]?.forEach { $0.entity(in: game)?.isEnabled = false }

		// Set position for pieces in play
		viewModel.gameState.allUnitsInPlay.forEach {
			guard let entity = $0.key.entity(in: game) else { return }
			entity.position = $0.value.vector
			entity.isEnabled = true
		}
	}

	private func present(
		deselectedPiece: GameViewModel.DeselectedPiece?,
		selectedPiece: GameViewModel.SelectedPiece?
	) {
		guard let game = viewModel.gameAnchor else { return }
		game.openPosition?.isEnabled = false

		viewModel.gameState.unitsInHand[viewModel.playingAs]?.forEach {
			$0.entity(in: game)?.isEnabled = false
		}

		guard let piece = selectedPiece?.piece, let position = selectedPiece?.position else { return }

		#warning("FIXME: should use Position")
		let entity = piece.entity(in: game)
		entity?.position = position.vector
		entity?.isEnabled = true
	}

	private func handleTransition(to newState: HiveGameViewModel.State) {
		switch newState {
		case .gameStart:
			prepareGame()
		case .playerTurn:
			startPlayerTurn()
			resetForPlayerTurn()
		case .opponentTurn:
			resetForPlayerTurn()
		case .begin, .gameEnd, .forfeit, .sendingMovement, .shutDown:
			break
		}
	}

	private func prepareGame() {
		guard let game = viewModel.gameAnchor else { return }
		arView.scene.anchors.append(game)
		game.visit { $0.synchronization = nil }
		resetGame()

		#warning("FIXME: move this to function to show/remove when debug enabled/disabled")
		if let gridPosition = game.gridPosition {
			for x in -4...4 {
				for z in -4...4 {
					let position = Position(x: x, y: -z - x, z: z)
					let clone = gridPosition.clone(recursive: true)
					let textEntity = clone.findEntity(named: "PositionText")!.children[0].children[0]
					var textModel: ModelComponent = textEntity.components[ModelComponent]!
					textModel.mesh = .generateText(
						position.description,
						extrusionDepth: 0.005,
						font: .systemFont(ofSize: 0.0175),
						containerFrame: CGRect.zero,
						alignment: .center,
						lineBreakMode: .byCharWrapping
					)
					textEntity.components.set(textModel)
					clone.position = position.vector
					game.addChild(clone)
				}
			}
			gridPosition.isEnabled = false
		}

		viewModel.postViewAction(.viewContentReady)
	}

	private func resetGame() {
		guard let game = viewModel.gameAnchor else { return }
		game.allPieces.forEach { $0?.isEnabled = false }
		game.openPosition?.position = Position.origin.vector
	}

	private func startPlayerTurn() {
		guard let game = viewModel.gameAnchor else { return }
		game.pieces(for: viewModel.playingAs)
			.forEach {
				guard let entity = $0 as? Entity & HasCollision else { return }
				let gestureRecognizers = arView.installGestures([.translation], for: entity)
				if let gestureRecognizer = gestureRecognizers.first as? EntityTranslationGestureRecognizer {
					gestureRecognizer.removeTarget(nil, action: nil)
					gestureRecognizer.addTarget(self, action: #selector(self.handlePieceTranslation))
				}
			}
	}

	private func resetForPlayerTurn() {
		#warning("TODO: reset pieces to positions for a player's turn")
	}

	private var initialTouchPosition: SIMD3<Float>?
	private var snappingPositions: [SIMD3<Float>]? {
		didSet {
			if let snappingPositions = snappingPositions {
				viewModel.debugLog("Updated snapping positions: \(snappingPositions)")
				viewModel.gameAnchor?.updateSnappingPositions(snappingPositions)
			} else {
				viewModel.gameAnchor?.removeSnappingPositions()
			}
		}
	}

	@objc func handlePieceTranslation(_ recognizer: EntityTranslationGestureRecognizer) {
		#warning("FIXME: should send snap position to viewModel so it can update")
		guard let game = viewModel.gameAnchor,
			let entity = recognizer.entity,
			let gamePiece = entity.gamePiece,
			let location = recognizer.location(in: game) else {
			return
		}

		self.debugOverlay.debugInfo = DebugInfo(touchPosition: .simd3(location), hivePosition: location.position)

		if recognizer.state == .began {
			initialTouchPosition = location
			snappingPositions = generateSnappingPositions(for: gamePiece)
		} else if recognizer.state == .ended || recognizer.state == .cancelled {
			initialTouchPosition = nil
			snappingPositions = nil
			viewModel.postViewAction(.gamePieceMoved(gamePiece, entity.position.position))
		}

		guard recognizer.state == .changed else { return }

		if let snappingPositions = snappingPositions, let firstPosition = snappingPositions.first {
			let initialClosest = (location.euclideanDistance(to: firstPosition), firstPosition)
			let closest = snappingPositions.reduce(initialClosest) { (previous, snappingPosition) in
				let distance = location.euclideanDistance(to: snappingPosition)
				return distance < previous.0 ? (distance, snappingPosition) : previous
			}

			if closest.0 < 0.05 {
				entity.position = closest.1
				return
			}
		}

		entity.position = SIMD3(x: location.x, y: 0, z: location.z)
	}

	private func generateSnappingPositions(for piece: Piece) -> [SIMD3<Float>] {
		Set(viewModel.gameState.availableMoves
			.filter { $0.movedUnit == piece }
			.compactMap { $0.targetPosition })
			.map { $0.vector }
	}
}

// MARK: - ARSessionDelegate

extension GameViewAR: ARSessionDelegate {
	func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
	}
}

// MARK: - ARCoachingOverlayViewDelegate

extension GameViewAR: ARCoachingOverlayViewDelegate {
	func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
		viewModel.postViewAction(.viewInteractionsReady)
		coachingOverlayView.removeFromSuperview()
	}
}

// MARK: - Debug

extension GameViewAR {
	private var debugEnabled: Bool {
		get {
			viewModel.debugModeStore.value
		}
		set {
			DispatchQueue.main.async {
				self.debugOverlay.enabled = newValue
			}
		}
	}

	override var canBecomeFirstResponder: Bool {
		true
	}

	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			viewModel.postViewAction(.toggleDebug)
		}
	}
}

#endif
