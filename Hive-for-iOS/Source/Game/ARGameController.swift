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
	func gameController(error: Error)
}

class ARGameController {
	private var state: GameState
	private var gameAnchor: Experience.HiveGame!

	weak var delegate: ARGameControllerDelegate?

	init(state: GameState) {
		self.state = state
	}

	func setupExperience(inView arView: ARView) {
		let arConfiguration = ARWorldTrackingConfiguration()
		arConfiguration.isCollaborationEnabled = true
		arConfiguration.planeDetection = .horizontal

		arView.session.run(arConfiguration)

		Experience.loadHiveGameAsync { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let hiveGame):
				break
			case .failure(let error):
				self.delegate?.gameController(error: error)
			}
		}
	}
}
