//
//  ARGameViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine
import HiveEngine

enum ARGameTask: Identifiable {
	var id: String {
		return ""
	}
}

enum ARGameViewAction: BaseViewAction {

}

class ARGameViewModel: ViewModel<ARGameViewAction, ARGameTask>, ObservableObject {
	@Published var informationToPresent: GameInformation?
	@Published var gameState: GameState!

	var hasInformation: Binding<Bool> {
		return Binding(
			get: { self.informationToPresent != nil },
			set: { _ in self.informationToPresent = nil }
		)
	}

	override func postViewAction(_ viewAction: ARGameViewAction) {

	}
}
