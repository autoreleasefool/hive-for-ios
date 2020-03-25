//
//  Hive2DViewController.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-21.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import SpriteKit

class Hive2DGameViewController: UIViewController {
	private let viewModel: HiveGameViewModel

	init(viewModel: HiveGameViewModel) {
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
		let scene = HiveGameScene(viewModel: viewModel, size: view.bounds.size)
		guard let view = view as? SKView else { fatalError("Hive2DGameViewController view must be SKView") }
		view.showsFPS = true
		view.showsNodeCount = true
		view.ignoresSiblingOrder = true
		scene.scaleMode = .resizeFill
		view.presentScene(scene)
		becomeFirstResponder()

		subscribeToPublishers()
	}

	private func subscribeToPublishers() {
		viewModel.loafSubject.sink { [weak self] receivedValue in
			receivedValue.build(withSender: self).show()
		}.store(in: viewModel)
	}
}

// MARK: - UIViewControllerRepresentable

struct Hive2DGame: UIViewControllerRepresentable {
	@Binding var viewModel: HiveGameViewModel

	func makeUIViewController(context: Context) -> Hive2DGameViewController {
		return Hive2DGameViewController(viewModel: viewModel)
	}

	func updateUIViewController(_ uiViewController: Hive2DGameViewController, context: Context) {}
}

// MARK: - Debug

extension Hive2DGameViewController {
	override var canBecomeFirstResponder: Bool {
		true
	}

	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			viewModel.postViewAction(.toggleDebug)
		}
	}
}
