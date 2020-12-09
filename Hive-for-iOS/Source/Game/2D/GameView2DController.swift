//
//  GameView2DController.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-21.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import SpriteKit

class GameView2DController: UIViewController {
	private let viewModel: GameViewModel

	init(viewModel: GameViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		self.view = SKView()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		let scene = GameView2D(viewModel: viewModel, size: view.bounds.size)
		guard let view = view as? SKView else { fatalError("GameView2DController view must be SKView") }
		view.ignoresSiblingOrder = true
		scene.scaleMode = .resizeFill
		view.presentScene(scene)
		becomeFirstResponder()

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

struct GameView2DContainer: UIViewControllerRepresentable {
	let viewModel: GameViewModel

	func makeUIViewController(context: Context) -> GameView2DController {
		GameView2DController(viewModel: viewModel)
	}

	func updateUIViewController(_ uiViewController: GameView2DController, context: Context) {}
}

// MARK: - Debug

extension GameView2DController {
	override var canBecomeFirstResponder: Bool {
		true
	}
}
