//
//  HiveGameViewController.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import UIKit
import RealityKit
import HiveEngine

protocol HiveGameDelegate: class {
	func exitGame()
	func show(information: GameInformation)
}

class HiveGameViewController: UIViewController {
	private var arView = ARView(frame: .zero)
	private var gameState: GameState

	weak var delegate: HiveGameDelegate?

	init(state: GameState) {
		self.gameState = state
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		setupView()

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
		view.addSubview(arView)
		arView.constrainToFillView(view)
	}
}
