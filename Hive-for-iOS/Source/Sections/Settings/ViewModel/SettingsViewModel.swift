//
//  SettingsViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-17.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

enum SettingsViewAction: BaseViewAction {
	case onAppear
	case switchGameMode(current: Preferences.GameMode)

	case logout
	case exit
}

enum SettingsAction: BaseAction {
	case loadProfile
	case setGameMode(Preferences.GameMode)
	case logout
}

class SettingsViewModel: ViewModel<SettingsViewAction>, ObservableObject {
	@Published var logoutResult: Loadable<Bool> {
		didSet {
			switch logoutResult {
			case .failed, .loaded:
				isOpen.wrappedValue = false
			case .loading, .notLoaded:
				break
			}
		}
	}

	private var isOpen: Binding<Bool>

	private let actions = PassthroughSubject<SettingsAction, Never>()
	var actionsPublisher: AnyPublisher<SettingsAction, Never> {
		actions.eraseToAnyPublisher()
	}

	init(isOpen: Binding<Bool>, logoutResult: Loadable<Bool>) {
		self.isOpen = isOpen
		self._logoutResult = .init(initialValue: logoutResult)
	}

	override func postViewAction(_ viewAction: SettingsViewAction) {
		switch viewAction {
		case .onAppear:
			actions.send(.loadProfile)
		case .switchGameMode(let current):
			switchGameMode(from: current)

		case .exit:
			isOpen.wrappedValue = false
		case .logout:
			actions.send(.logout)
		}
	}

	private func switchGameMode(from gameMode: Preferences.GameMode) {
		let next: Preferences.GameMode
		switch gameMode {
		case .ar: next = .sprite
		case .sprite: next = .ar
		}

		actions.send(.setGameMode(next))
	}
}
