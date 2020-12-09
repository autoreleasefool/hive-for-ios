//
//  SettingsListViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-17.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

enum SettingsListViewAction: BaseViewAction {
	case onAppear
	case switchGameMode(current: Preferences.GameMode)
	case switchPieceColorScheme(current: Preferences.PieceColorScheme)
	case appStateChanged

	case logout
	case exit
}

enum SettingsListAction: BaseAction {
	case loadProfile
	case setGameMode(Preferences.GameMode)
	case setPieceColorScheme(Preferences.PieceColorScheme)
	case logout
	case closeSettings
}

class SettingsListViewModel: ViewModel<SettingsListViewAction>, ObservableObject {
	@Published var logoutResult: Loadable<Bool> {
		didSet {
			switch logoutResult {
			case .failed, .loaded:
				actions.send(.closeSettings)
			case .loading, .notLoaded:
				break
			}
		}
	}

	@Published var user: Loadable<User>
	@Published var showAttributions: Bool = false
	@Published var showAccount: Bool
	@Published var preferences = Preferences()
	let inGame: Bool

	private let actions = PassthroughSubject<SettingsListAction, Never>()
	var actionsPublisher: AnyPublisher<SettingsListAction, Never> {
		actions.eraseToAnyPublisher()
	}

	init(user: Loadable<User>, logoutResult: Loadable<Bool>, showAccount: Bool, inGame: Bool) {
		_user = .init(initialValue: user)
		_logoutResult = .init(initialValue: logoutResult)
		self.inGame = inGame
		self.showAccount = showAccount
	}

	override func postViewAction(_ viewAction: SettingsListViewAction) {
		switch viewAction {
		case .onAppear:
			actions.send(.loadProfile)
		case .switchGameMode(let current):
			switchGameMode(from: current)
		case .switchPieceColorScheme(let current):
			switchPieceColorScheme(from: current)
		case .appStateChanged:
			objectWillChange.send()

		case .exit:
			actions.send(.closeSettings)
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

	private func switchPieceColorScheme(from colorScheme: Preferences.PieceColorScheme) {
		let next: Preferences.PieceColorScheme
		switch colorScheme {
		case .filled: next = .outlined
		case .outlined: next = .filled
		}

		actions.send(.setPieceColorScheme(next))
	}
}
