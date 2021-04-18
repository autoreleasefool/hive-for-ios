//
//  LocalRoomViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-06-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import HiveEngine
import HiveFoundation
import SwiftUI

enum LocalRoomViewAction: BaseViewAction {
	case startGame

	case requestExit
	case exitMatch
	case dismissExit
}

enum LocalRoomAction: BaseAction {
	case startGame
	case exitMatch
	case failedToJoinMatch
}

class LocalRoomViewModel: ViewModel<LocalRoomViewAction>, ObservableObject {
	@Published private(set) var matchOptions: Set<Match.Option> = Match.Option.defaultOfflineSet
	@Published private(set) var gameOptions: Set<GameState.Option> = GameState().options

	@Published var exiting = false

	private let actions = PassthroughSubject<LocalRoomAction, Never>()
	var actionsPublisher: AnyPublisher<LocalRoomAction, Never> {
		actions.eraseToAnyPublisher()
	}

	private(set) var opponent: LocalOpponent

	var match: Match {
		Match.createOfflineMatch(
			against: opponent,
			withOptions: matchOptions,
			withGameOptions: gameOptions
		)
	}

	var player: Player {
		matchOptions.contains(.hostIsWhite) ? .white : .black
	}

	var initialGameState: GameState {
		if let envGameString = ProcessInfo.processInfo.environment["LocalGameString"],
			 let gameString = GameString(from: envGameString) {
			return gameString.state
		}
		return GameState(options: gameOptions)
	}

	init(opponent: LocalOpponent) {
		self.opponent = opponent
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
		actions.send(.startGame)
	}

	func optionEnabled(option: Match.Option) -> Binding<Bool> {
		Binding(
			get: { [weak self] in self?.matchOptions.contains(option) ?? false },
			set: { [weak self] newValue in self?.matchOptions.set(option, to: newValue) }
		)
	}

	func gameOptionEnabled(option: GameState.Option) -> Binding<Bool> {
		Binding(
			get: { [weak self] in self?.gameOptions.contains(option) ?? false },
			set: { [weak self] newValue in self?.gameOptions.set(option, to: newValue) }
		)
	}
}

// MARK: - Strings

extension LocalRoomViewModel {
	var title: String {
		"VS Computer"
	}
}
