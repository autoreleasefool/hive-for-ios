//
//  HiveARViewController.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit
import HiveEngine
import Loaf

class HiveARGameViewController: UIViewController {

	private var viewModel: HiveGameViewModel

	private var arView = ARView(frame: .zero)
	private var gameAnchor: Experience.HiveGame!

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

		setupExperience()
	}

	private func setupExperience() {
		arView.automaticallyConfigureSession = false

		let arConfiguration = ARWorldTrackingConfiguration()
		arConfiguration.isCollaborationEnabled = true
		arConfiguration.planeDetection = .horizontal

		arView.session.delegate = self
		arView.session.run(arConfiguration, options: [])

		Experience.loadHiveGameAsync { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let hiveGame):
				if self.gameAnchor == nil {
					self.gameAnchor = hiveGame
					self.viewModel.postViewAction(.contentDidLoad)
				}
			case .failure(let error):
				self.viewModel.postViewAction(.arViewError(error))
			}
		}
	}

	private func restartGame() {
		guard let game = gameAnchor else { return }

		// Hide pieces for a new game
		game.visit { entity in
			entity.isEnabled = false
		}
	}
}

// MARK: - ARSessionDelegate

extension HiveARGameViewController: ARSessionDelegate {

}

// MARK: - UIViewControllerRepresentable

struct HiveARGame: UIViewControllerRepresentable {
	@Binding var viewModel: HiveGameViewModel

	func makeUIViewController(context: Context) -> HiveARGameViewController {
		return HiveARGameViewController(viewModel: viewModel)
	}

	func updateUIViewController(_ uiViewController: HiveARGameViewController, context: Context) {}
}
