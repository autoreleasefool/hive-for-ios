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

class HiveARGameViewController: UIViewController {

	private var viewModel: HiveGameViewModel

	private var arView = ARView(frame: .zero)

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

		subscribeToPublishers()
		setupExperience()
	}

	private func subscribeToPublishers() {
		viewModel.flowState
			.sink { [weak self] receivedValue in
				self?.handleTransition(to: receivedValue)
			}
			.store(in: viewModel)

		viewModel.selectedPiece
			.sink { [weak self] receivedValue in
				self?.presentSelectedPiece(receivedValue)
			}
			.store(in: viewModel)
	}

	private func setupExperience() {
		#if targetEnvironment(simulator)
		return
		#else
		arView.automaticallyConfigureSession = false

		let arConfiguration = ARWorldTrackingConfiguration()
		arConfiguration.isCollaborationEnabled = false
		arConfiguration.planeDetection = .horizontal

		arView.session.delegate = self
		arView.session.run(arConfiguration, options: [])

		Experience.loadHiveGameAsync { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let hiveGame):
				self.viewModel.postViewAction(.viewContentDidLoad(.arExperience(hiveGame)))
			case .failure(let error):
				self.viewModel.postViewAction(.arViewError(error))
			}
		}
		#endif
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

	private func presentSelectedPiece(_ pieceClass: Piece.Class) {
		guard let game = viewModel.gameAnchor else { return }
		let pieces = game.pieces(for: viewModel.playingAs)
		if let piece = pieces.first(where: { $0?.gamePiece?.class == pieceClass && $0?.isEnabled == false }) {
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

		viewModel.postViewAction(.viewContentReady)
	}

	private func resetGame() {
		guard let game = viewModel.gameAnchor else { return }

		// Hide pieces for a new game
		game.allPieces.forEach { $0?.isEnabled = false }
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

	@objc func handlePieceTranslation(_ recognizer: EntityTranslationGestureRecognizer) {
		guard let game = viewModel.gameAnchor,
			let entity = recognizer.entity,
			recognizer.state == .changed else {
			return
		}

		entity.position = recognizer.location(in: game) ?? entity.position
	}
}

// MARK: - ARSessionDelegate

extension HiveARGameViewController: ARSessionDelegate {
	func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
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
