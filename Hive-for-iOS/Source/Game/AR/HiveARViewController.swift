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

		subscribeToPublishers()
		setupExperience()
	}

	private func subscribeToPublishers() {
		let gameLoaded = viewModel.gameLoaded.sink { [weak self] _ in
			guard let game = self?.viewModel.gameAnchor else { return }
			self?.arView.scene.anchors.append(game)
		}
		viewModel.register(cancellable: gameLoaded, withId: .arGameLoaded)
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
				self.viewModel.postViewAction(.contentDidLoad(hiveGame))
			case .failure(let error):
				self.viewModel.postViewAction(.arViewError(error))
			}
		}
		#endif
	}

	private func restartGame() {
		guard let game = viewModel.gameAnchor else { return }

		// Hide pieces for a new game
		game.visit { entity in
			entity.synchronization = nil
			entity.isEnabled = false
		}
	}
}

// MARK: - ARSessionDelegate

extension HiveARGameViewController: ARSessionDelegate {
//	func sess
}

// MARK: - UIViewControllerRepresentable

struct HiveARGame: UIViewControllerRepresentable {
	@Binding var viewModel: HiveGameViewModel

	func makeUIViewController(context: Context) -> HiveARGameViewController {
		return HiveARGameViewController(viewModel: viewModel)
	}

	func updateUIViewController(_ uiViewController: HiveARGameViewController, context: Context) {}
}
