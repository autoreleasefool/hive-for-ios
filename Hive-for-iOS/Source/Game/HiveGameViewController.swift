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
		view.backgroundColor = .red
		view.isUserInteractionEnabled = true

		DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
			self?.delegate?.exitGame()
		}
	}

	private func setupView() {
		view.addSubview(arView)
		NSLayoutConstraint.activate([
			arView.topAnchor.constraint(equalTo: view.topAnchor),
			arView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			arView.leftAnchor.constraint(equalTo: view.leftAnchor),
			arView.rightAnchor.constraint(equalTo: view.rightAnchor),
		])
	}
}
