//
//  GameContainer.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine
import Loaf

struct GameContainer: View {
	@Binding var gameIsActive: Bool
	@State var viewModel = ARGameViewModel()

	init(isActive: Binding<Bool>, state: GameState) {
		_gameIsActive = isActive
		viewModel.gameState = state
	}

	var body: some View {
		ZStack {
			GameViewController(shouldBePresented: $gameIsActive, viewModel: $viewModel)
			GameHUD()
				.environmentObject(viewModel)
		}
		.edgesIgnoringSafeArea(.all)
		.navigationBarTitle("")
		.navigationBarHidden(true)
		.loaf($viewModel.errorLoaf)
	}
}

struct GameViewController: UIViewControllerRepresentable {
	@Binding var shouldBePresented: Bool
	@Binding var viewModel: ARGameViewModel

	func makeUIViewController(context: Context) -> HiveGameViewController {
		let controller = HiveGameViewController(state: viewModel.gameState)
		controller.delegate = context.coordinator
		return controller
	}

	func updateUIViewController(_ uiViewController: HiveGameViewController, context: Context) {

	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: HiveGameDelegate {
		var parent: GameViewController

		init(_ parent: GameViewController) {
			self.parent = parent
		}

		func exitGame() {
			#warning("TODO: pop to room list")
			parent.shouldBePresented = false
		}

		func show(information: GameInformation) {
			parent.viewModel.informationToPresent = information
		}

		func error(loaf: Loaf) {
			parent.viewModel.errorLoaf = loaf
		}
	}
}
