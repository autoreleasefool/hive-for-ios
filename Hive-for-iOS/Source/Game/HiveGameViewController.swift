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

protocol HiveGameDelegate: class {
	func exitGame()
	func show(information: GameInformation)
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

		let arConfiguration = ARWorldTrackingConfiguration()
		arConfiguration.planeDetection = .horizontal
		arView.session.run(arConfiguration)

		Experience.lo

		if let hiveAnchor = try? Experience.loadHiveGame() {
			arView.scene.anchors.append(hiveAnchor)
		}


		DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
			self?.delegate?.show(information: .unit(.init(class: .ant, owner: .white, index: 1)))
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
			self?.delegate?.show(information: .unit(.init(class: .queen, owner: .black, index: 1)))
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
			self?.delegate?.exitGame()
		}
	}

	private func setupView() {

	}
}
