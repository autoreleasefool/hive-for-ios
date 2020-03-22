//
//  HiveARViewController.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine
import RealityKit
import ARKit
import HiveEngine
import Loaf

#if targetEnvironment(simulator)

class HiveARGameViewController: UIViewController { }

#else

class HiveARGameViewController: UIViewController {

	private var viewModel: HiveGameViewModel

	private var arView = ARView(frame: .zero)

	private let debugOverlay = DebugOverlay(enabled: true)

	init(viewModel: HiveGameViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(arView)
		arView.constrainToFillView(view)
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapArView))
		arView.addGestureRecognizer(tapGesture)

		view.addSubviewForAutoLayout(debugOverlay)
		NSLayoutConstraint.activate([
			debugOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			debugOverlay.topAnchor.constraint(equalTo: view.topAnchor),
		])

		subscribeToPublishers()
		setupExperience()
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

	private func present(selectedPiece pieceClass: Piece.Class?) {
		guard let game = viewModel.gameAnchor else { return }
		game.openPosition?.isEnabled = false

		viewModel.gameState.unitsInHand[viewModel.playingAs]?.forEach {
			$0.entity(in: game)?.isEnabled = false
		}

		guard let pieceClass = pieceClass else { return }

		let pieces = game.pieces(for: viewModel.playingAs)
		if let piece = pieces.first(where: { $0?.gamePiece?.class == pieceClass && $0?.isEnabled == false }) {
			piece?.position = SIMD3(x: 0, y: 0, z: 0.3)
			piece?.isEnabled = true
		}
	}

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
		guard let game = viewModel.gameAnchor else { return }
		arView.scene.anchors.append(game)
		game.visit { $0.synchronization = nil }
		resetGame()

		if let gridPosition = game.gridPosition {
			for x in -4...4 {
//				for y in -4...4 {
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
//				}
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
		guard let game = viewModel.gameAnchor,
			let entity = recognizer.entity,
			let gamePiece = entity.gamePiece,
			let location = recognizer.location(in: game) else {
			return
		}

		self.debugOverlay.debugInfo = DebugInfo(touchPosition: location, hivePosition: location.position)

		if recognizer.state == .began {
			initialTouchPosition = location
			snappingPositions = generateSnappingPositions(for: gamePiece)
		} else if recognizer.state == .ended || recognizer.state == .cancelled {
			initialTouchPosition = nil
			snappingPositions = nil
			viewModel.postViewAction(.gamePieceMoved(gamePiece, entity.position.position))
		}

		guard recognizer.state == .changed else { return }

		if let snappingPositions = snappingPositions, snappingPositions.count > 0 {
			let firstPosition = snappingPositions.first!
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

extension HiveARGameViewController: ARSessionDelegate {
	func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
	}
}

// MARK: - ARCoachingOverlayViewDelegate

extension HiveARGameViewController: ARCoachingOverlayViewDelegate {
	func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
		viewModel.postViewAction(.viewInteractionsReady)
		coachingOverlayView.removeFromSuperview()
	}
}

// MARK: - UIViewControllerRepresentable

struct HiveARGame: UIViewControllerRepresentable {
	@Binding var viewModel: HiveGameViewModel

	func makeUIViewController(context: Context) -> HiveARGameViewController {
		return HiveARGameViewController(viewModel: viewModel)
	}

	func updateUIViewController(_ uiViewController: HiveARGameViewController, context: Context) {}
}

// MARK: - Debug

extension HiveARGameViewController {
	private var debugEnabled: Bool {
		get {
			viewModel.debugEnabledSubject.value
		}
		set {
			DispatchQueue.main.async {
				self.debugOverlay.enabled = newValue
			}
		}
	}

	override var canBecomeFirstResponder: Bool {
		get { true }
	}

	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			viewModel.postViewAction(.toggleDebug)
		}
	}
}

#endif
