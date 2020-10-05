//
//  GameViewARController.swift
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

#if targetEnvironment(simulator)

class GameViewARController: UIViewController { }

#else

class GameViewARController: UIViewController {
	private var viewModel: GameViewModel

	init(viewModel: GameViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		#if AR_ENABLED
		self.view = GameViewAR(viewModel: viewModel)
		#else
		super.loadView()
		#endif
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		subscribeToPublishers()
	}

	private func subscribeToPublishers() {
		viewModel.loafState.sink { [weak self] in
			guard let self = self else { return }
			$0.show(withSender: self)
		}.store(in: viewModel)
	}
}

// MARK: - UIViewControllerRepresentable

struct GameViewARContainer: UIViewControllerRepresentable {
	let viewModel: GameViewModel

	func makeUIViewController(context: Context) -> GameViewARController {
		GameViewARController(viewModel: viewModel)
	}

	func updateUIViewController(_ uiViewController: GameViewARController, context: Context) {}
}

#endif
