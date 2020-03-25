//
//  HiveARViewController.swift
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

class HiveARViewController: UIViewController { }

#else

class HiveARViewController: UIViewController {
	private var viewModel: HiveGameViewModel

	init(viewModel: HiveGameViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		self.view = HiveARGameView(viewModel: viewModel)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		subscribeToPublishers()
	}

	private func subscribeToPublishers() {
		viewModel.loafSubject.sink { [weak self] receivedValue in
			receivedValue.build(withSender: self).show()
		}.store(in: viewModel)

		viewModel.actionsSubject.sink { [weak self] receivedValue in
			self?.present(receivedValue.alertController(), animated: true, completion: nil)
		}.store(in: viewModel)
	}
}


// MARK: - UIViewControllerRepresentable

struct HiveARGame: UIViewControllerRepresentable {
	@Binding var viewModel: HiveGameViewModel

	func makeUIViewController(context: Context) -> HiveARViewController {
		return HiveARViewController(viewModel: viewModel)
	}

	func updateUIViewController(_ uiViewController: HiveARViewController, context: Context) {}
}

#endif
