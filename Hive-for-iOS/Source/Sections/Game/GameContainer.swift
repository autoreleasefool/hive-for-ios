//
//  GameContainer.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct GameContainer: View {
	@Binding var gameIsActive: Bool
	@State var viewModel = ARGameViewModel()

	init(isActive: Binding<Bool>) {
		_gameIsActive = isActive
	}

	var body: some View {
		ZStack {
			GameController(shouldBePresented: $gameIsActive, viewModel: $viewModel)
			GameHUD()
				.environmentObject(viewModel)
		}
		.edgesIgnoringSafeArea(.all)
		.navigationBarTitle("")
		.navigationBarHidden(true)
	}
}

struct GameController: UIViewControllerRepresentable {
	@Binding var shouldBePresented: Bool
	@Binding var viewModel: ARGameViewModel

	func makeUIViewController(context: Context) -> HiveGameViewController {
		let controller = HiveGameViewController()
		controller.delegate = context.coordinator
		return controller
	}

	func updateUIViewController(_ uiViewController: HiveGameViewController, context: Context) {

	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: HiveGameDelegate {
		var parent: GameController

		init(_ parent: GameController) {
			self.parent = parent
		}

		func exitGame() {
			#warning("TODO: pop to room list")
			parent.shouldBePresented = false
		}

		func showInformation(for piece: HiveEngine.Unit) {

		}
	}
}
