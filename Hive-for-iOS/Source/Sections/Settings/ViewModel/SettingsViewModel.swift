//
//  SettingsViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-17.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine

enum SettingsViewAction: BaseViewAction {
	case logout
	case exit
}

enum SettingsAction: BaseAction {
	case logout
	case exit
}

class SettingsViewModel: ViewModel<SettingsViewAction>, ObservableObject {
	@Published var logoutResult: Loadable<Bool> {
		didSet {
			switch logoutResult {
			case .failed, .loaded: actions.send(.exit)
			case .loading, .notLoaded: break
			}
		}
	}

	private let actions = PassthroughSubject<SettingsAction, Never>()
	var actionsPublisher: AnyPublisher<SettingsAction, Never> {
		actions.eraseToAnyPublisher()
	}

	init(logoutResult: Loadable<Bool>) {
		self._logoutResult = .init(initialValue: logoutResult)
	}

	override func postViewAction(_ viewAction: SettingsViewAction) {
		switch viewAction {
		case .exit:
			actions.send(.exit)
		case .logout:
			actions.send(.logout)
		}
	}
}
