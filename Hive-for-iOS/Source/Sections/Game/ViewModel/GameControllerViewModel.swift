//
//  GameControllerViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine

enum GameControllerTask: Identifiable {
	case test

	var id: String {
		return "test"
	}
}

enum GameControllerViewAction: BaseViewAction {
	case onAppeared
	case onDisappeared
}

class GameControllerViewModel: ViewModel<GameControllerViewAction, GameControllerTask>, ObservableObject {
	override func postViewAction(_ viewAction: GameControllerViewAction) {
		switch viewAction {
		case .onAppeared:
			break
		case .onDisappeared:
			break
		}
	}
}
