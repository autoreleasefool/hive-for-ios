//
//  LocalRoomViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-06-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

enum LocalRoomViewAction: BaseViewAction {
	case startGame

	case requestExit
	case exitMatch
	case dismissExit
}

enum LocalRoomAction: BaseAction {
	case exitMatch
}

class LocalRoomViewModel: ViewModel<LocalRoomViewAction>, ObservableObject {
	@Published var exiting = false

	private let actions = PassthroughSubject<LocalRoomAction, Never>()
	var actionsPublisher: AnyPublisher<LocalRoomAction, Never> {
		actions.eraseToAnyPublisher()
	}

	override func postViewAction(_ viewAction: LocalRoomViewAction) {
		switch viewAction {
		case .startGame:
			startGame()

		case .requestExit:
			exiting = true
		case .exitMatch:
			exiting = false
			actions.send(.exitMatch)
		case .dismissExit:
			exiting = false
		}
	}

	private func startGame() {

	}
}

// MARK: - Strings

extension LocalRoomViewModel {
	var title: String {
		"VS Computer"
	}
}
