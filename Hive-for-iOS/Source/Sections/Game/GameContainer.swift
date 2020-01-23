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

	var body: some View {
		GameController(isActive: $isActive)
			.edgesIgnoringSafeArea(.all)
			.navigationBarTitle("")
			.navigationBarHidden(true)
	}
}

struct GameController: UIViewControllerRepresentable {
	@Binding var isActive: Bool

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
			self.parent.isActive = false
		}
	}
}

