//
//  HiveStateMachine.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-25.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import ARKit
import RealityKit
import HiveEngine

protocol ARGameControllerDelegate: class {
	func gameControllerDidRaiseError(_ gameController: ARGameController, error: Error)
	func gameControllerContentDidLoad(_ gameController: ARGameController)
}

class ARGameController: NSObject {
	private(set) var state: GameState
	private(set) var gameAnchor: Experience.HiveGame!

	weak var delegate: ARGameControllerDelegate?

	init(state: GameState) {
		self.state = state
	}

	func setupExperience(inView arView: ARView) {
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
					self.delegate?.gameControllerContentDidLoad(self)
				}
			case .failure(let error):
				self.delegate?.gameControllerDidRaiseError(self, error: error)
			}
		}
	}
}

// MARK: - ARSessionDelegate

extension ARGameController: ARSessionDelegate {
	func session(_ session: ARSession, didUpdate frame: ARFrame) {

	}
}
