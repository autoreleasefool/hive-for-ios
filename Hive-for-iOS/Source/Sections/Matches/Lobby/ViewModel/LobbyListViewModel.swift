//
//  LobbyListViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

enum LobbyListViewAction: BaseViewAction {
	case onAppear(isOffline: Bool, aiEnabled: Bool)
	case refresh
	case openSettings
	case networkStatusChanged(isOffline: Bool)
	case aiModeToggled(Bool)
	case featuresChanged
	case offlineStateAction

	case joinMatch(Match.ID)
	case createNewMatch
	case createOnlineMatchVsPlayer
	case createLocalMatchVsComputer
	case cancelCreateMatch
}

enum LobbyListAction: BaseAction {
	case loadMatches
	case openSettings
	case goOnline
}

class LobbyListViewModel: ViewModel<LobbyListViewAction>, ObservableObject {

	@Published var creatingOnlineRoom = false {
		didSet {
			if !creatingOnlineRoom && currentMatchId != nil {
				currentMatchId = nil
			}
		}
	}

	@Published var creatingLocalRoom = false {
		didSet {
			if !creatingLocalRoom && currentMatchId != nil {
				currentMatchId = nil
			}
		}
	}

	@Published var currentMatchId: Match.ID? {
		didSet {
			if currentMatchId == nil {
				if creatingOnlineRoom {
					creatingOnlineRoom = false
				}
				if creatingLocalRoom {
					creatingLocalRoom = false
				}
			}
		}
	}

	@Published var currentSpectatingMatchId: Match.ID?

	@Published var matches: Loadable<[Match]>
	@Published var showMatchInProgressWarning = false
	@Published var showCreateMatchPrompt = false
	@Published var isOffline = false {
		didSet {
			guard isOffline != oldValue else { return }
			accountStatusDidChange()
		}
	}

	let isSpectating: Bool
	private var isAIGameModeEnabled: Bool = false

	private let actions = PassthroughSubject<LobbyListAction, Never>()
	var actionsPublisher: AnyPublisher<LobbyListAction, Never> {
		actions.eraseToAnyPublisher()
	}

	init(isSpectating: Bool, matches: Loadable<[Match]>) {
		self.isSpectating = isSpectating
		self._matches = .init(initialValue: matches)
	}

	override func postViewAction(_ viewAction: LobbyListViewAction) {
		switch viewAction {
		case .onAppear(let isOffline, let aiEnabled):
			self.isOffline = isOffline
			self.isAIGameModeEnabled = aiEnabled
			accountStatusDidChange()
		case .refresh:
			actions.send(.loadMatches)
		case .openSettings:
			actions.send(.openSettings)
		case .createNewMatch:
			createNewMatch()
		case .joinMatch(let id):
			joinMatch(withId: id)
		case .createOnlineMatchVsPlayer:
			creatingOnlineRoom = true
			showCreateMatchPrompt = false
		case .createLocalMatchVsComputer:
			creatingLocalRoom = true
			showCreateMatchPrompt = false
		case .cancelCreateMatch:
			showCreateMatchPrompt = false
		case .networkStatusChanged(let isOffline):
			self.isOffline = isOffline
		case .aiModeToggled(let enabled):
			self.isAIGameModeEnabled = enabled
		case .featuresChanged:
			objectWillChange.send()
		case .offlineStateAction:
			performOfflineStateAction()
		}
	}

	private func joinMatch(withId id: Match.ID) {
		if inMatch {
			showMatchInProgressWarning = true
		} else {
			if isSpectating {
				currentSpectatingMatchId = id
			} else {
				currentMatchId = id
			}
		}
	}

	private func createNewMatch() {
		if inMatch {
			showMatchInProgressWarning = true
		} else {
			if isOffline {
				creatingLocalRoom = true
			} else if isAIGameModeEnabled {
				showCreateMatchPrompt = true
			} else {
				postViewAction(.createOnlineMatchVsPlayer)
			}
		}
	}

	private func accountStatusDidChange() {
		if isOffline {
			matches = .loaded([])
		} else {
			actions.send(.loadMatches)
		}
	}

	private func performOfflineStateAction() {
		if isSpectating {
			actions.send(.goOnline)
		} else {
			postViewAction(.createLocalMatchVsComputer)
		}
	}
}

extension LobbyListViewModel {
	var inMatch: Bool {
		creatingOnlineRoom || creatingLocalRoom || currentMatchId != nil
	}

	var joiningMatch: Binding<Bool> {
		Binding(
			get: { [weak self] in
				guard let self = self else { return false }
				return !self.creatingOnlineRoom && !self.creatingLocalRoom && self.currentMatchId != nil
			},
			set: { [weak self] in
				if !$0 {
					self?.currentMatchId = nil
				}
			}
		)
	}

	var spectatingMatch: Binding<Bool> {
		Binding(
			get: { [weak self] in self?.currentSpectatingMatchId != nil },
			set: { [weak self] in
				if !$0 {
					self?.currentSpectatingMatchId = nil
				}
			}
		)
	}
}

// MARK: - Strings

extension LobbyListViewModel {
	func offlineStateMessage(isAccountsEnabled: Bool, isGuestModeEnabled: Bool) -> String {
		if isSpectating {
			return isAccountsEnabled
				? "You can't spectate offline. Log in to spectate"
				: (isGuestModeEnabled
						? "You can't spectate offline. Go online to spectate"
						: "You can't spectate offline"
				)
		} else {
			return "You can play a game against the computer by tapping below"
		}
	}

	func offlineStateAction(isAccountsEnabled: Bool, isGuestModeEnabled: Bool) -> String? {
		if isSpectating {
			return isAccountsEnabled
				? "Log in"
				: (isGuestModeEnabled
						? "Play online"
						: nil
				)
		} else {
			return "Play local match"
		}
	}

	func errorMessage(from error: Error) -> String {
		guard let matchError = error as? MatchRepositoryError else {
			return error.localizedDescription
		}

		switch matchError {
		case .usingOfflineAccount: return "You're offline"
		case .apiError(let apiError): return apiError.errorDescription ?? apiError.localizedDescription
		}
	}
}
