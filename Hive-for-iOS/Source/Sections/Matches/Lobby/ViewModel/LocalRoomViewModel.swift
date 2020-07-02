//
//  LocalRoomViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-06-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI
import HiveEngine

enum LocalRoomViewAction: BaseViewAction {
	case createMatch
	case startGame

	case requestExit
	case exitMatch
	case dismissExit
}

enum LocalRoomAction: BaseAction {
	case exitMatch
}

class LocalRoomViewModel: ViewModel<LocalRoomViewAction>, ObservableObject {
	@Published var match: Loadable<Match> = .notLoaded {
		didSet {
			matchOptions = match.value?.optionSet ?? Set()
			gameOptions = match.value?.gameOptionSet ?? Set()
		}
	}

	@Published private(set) var matchOptions: Set<Match.Option> = Set()
	@Published private(set) var gameOptions: Set<GameState.Option> = Set()

	@Published var exiting = false

	private let actions = PassthroughSubject<LocalRoomAction, Never>()
	var actionsPublisher: AnyPublisher<LocalRoomAction, Never> {
		actions.eraseToAnyPublisher()
	}

	var opponent: ComputerEnemy.Player!

	var player: Player {
		matchOptions.contains(.hostIsWhite) ? .white : .black
	}

	override func postViewAction(_ viewAction: LocalRoomViewAction) {
		switch viewAction {
		case .createMatch:
			createMatch()
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

	private func createMatch() {

	}

	private func startGame() {

	}

	func optionEnabled(option: Match.Option) -> Binding<Bool> {
		Binding(
			get: { [weak self] in self?.matchOptions.contains(option) ?? false },
			set: { [weak self] newValue in
				guard let self = self else { return }
				self.matchOptions.set(option, to: newValue)
			}
		)
	}

	func gameOptionEnabled(option: GameState.Option) -> Binding<Bool> {
		Binding(
			get: { [weak self] in self?.gameOptions.contains(option) ?? false },
			set: { [weak self] newValue in
				guard let self = self else { return }
				self.gameOptions.set(option, to: newValue)
			}
		)
	}
}

// MARK: - Strings

extension LocalRoomViewModel {
	var title: String {
		"VS Computer"
	}
}
