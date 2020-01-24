//
//  GameContainer.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct GameContainer: View {
	@Binding var isActive: Bool
	@State var arGameState = ARGameState()

	init(isActive: Binding<Bool>) {
		_isActive = isActive
		print("new game container")
	}

	var body: some View {
		print("Wjy is GameContainer updating")

		return ZStack {
			GameController(isActive: $isActive, arGameState: $arGameState)
			GameHUD()
				.environmentObject(arGameState)
		}
			.edgesIgnoringSafeArea(.all)
			.navigationBarTitle("")
			.navigationBarHidden(true)
	}
}

struct GameController: UIViewControllerRepresentable {
	@Binding var isActive: Bool
	@Binding var arGameState: ARGameState

	func makeUIViewController(context: Context) -> HiveGameViewController {
		print("Creating game controller")
		let controller = HiveGameViewController()
		controller.delegate = context.coordinator
		return controller
	}

	func updateUIViewController(_ uiViewController: HiveGameViewController, context: Context) {
		print("Updating game controller")
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
			parent.isActive = false
		}

		func refreshInfo() {
			print("Updating info")
			parent.arGameState.updatePiece()
		}
	}
}
