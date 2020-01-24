//
//  HiveGameViewController.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import UIKit
import RealityKit

protocol HiveGameDelegate: class {
	func exitGame()
	func refreshInfo()
}

class HiveGameViewController: UIViewController {
	private var arView = ARView(frame: .zero)

	weak var delegate: HiveGameDelegate?

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		setupView()

		DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
			self?.delegate?.refreshInfo()
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
			self?.delegate?.refreshInfo()
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 12) { [weak self] in
			self?.delegate?.exitGame()
		}
	}

	private func setupView() {
		view.addSubview(arView)
		arView.constrainToFillView(view)
	}
}
