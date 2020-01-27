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
	}
}

// MARK: - ARGameControllerDelegate

extension HiveGameViewController: ARGameControllerDelegate {
	func gameController(error: Error) {
		delegate?.error(loaf: Loaf(error.localizedDescription, state: .error))
	}
}
