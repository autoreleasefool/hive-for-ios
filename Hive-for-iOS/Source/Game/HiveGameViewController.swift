//
//  HiveGameViewController.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import HiveEngine
import Loaf

protocol HiveGameDelegate: class {
	func exitGame()
	func show(information: GameInformation)
	func error(loaf: Loaf)
}

class HiveGameViewController: UIViewController {
	private var arView = ARView(frame: .zero)
	private var gameController: ARGameController
	weak var delegate: HiveGameDelegate?

	init(state: GameState) {
		self.gameController = ARGameController(state: state)
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(arView)
		arView.constrainToFillView(view)

		gameController.delegate = self
		gameController.setupExperience(inView: arView)

		arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(arViewPress)))
	}

	@objc private func arViewPress() {
		self.delegate?.show(information: .unit(HiveEngine.Unit(class: .ant, owner: .white, index: 1)))
	}

	fileprivate func restartGame() {
		guard let game = gameController.gameAnchor else { return }

		// Hide pieces for a new game
		game.visit { entity in
			entity.isEnabled = false
		}
	}
}

// MARK: - ARGameControllerDelegate

extension HiveGameViewController: ARGameControllerDelegate {
	func gameControllerDidRaiseError(_ gameController: ARGameController, error: Error) {
		delegate?.error(loaf: Loaf(error.localizedDescription, state: .error))
	}

	func gameControllerContentDidLoad(_ gameController: ARGameController) {
//		guard let game = gameController.gameAnchor else { return }
		self.restartGame()
	}
}
