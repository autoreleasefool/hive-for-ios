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
	case onAppear(isOffline: Bool)
	case onListAppear
	case onListDisappear
	case refresh
	case openSettings

	case joinMatch(Match.ID)
	case createNewMatch
	case createOnlineMatchVsPlayer
	case createLocalMatchVsComputer
	case cancelCreateMatch

	case logIn
}

enum LobbyListAction: BaseAction {
	case loadMatches
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
	@Published var settingsOpened = false
	@Published var showMatchInProgressWarning = false
	@Published var showCreateMatchPrompt = false
	@Published var isOffline = false

	let spectating: Bool

	private var refreshTimer: Timer?

	private let actions = PassthroughSubject<LobbyListAction, Never>()
	var actionsPublisher: AnyPublisher<LobbyListAction, Never> {
		actions.eraseToAnyPublisher()
	}

	init(spectating: Bool, matches: Loadable<[Match]>) {
		self.spectating = spectating
		self._matches = .init(initialValue: matches)
	}

	override func postViewAction(_ viewAction: LobbyListViewAction) {
		switch viewAction {
		case .onAppear(let isOffline):
			self.isOffline = isOffline
			initialize()
		case .onListAppear:
			startRefreshTimer()
		case .onListDisappear:
			refreshTimer?.invalidate()
		case .refresh:
			actions.send(.loadMatches)
		case .openSettings:
			settingsOpened = true
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

		case .logIn:
			#warning("TODO: Log in")
		}
	}

	private func initialize() {
		if self.isOffline {
			self.matches = .loaded([])
		} else {
			actions.send(.loadMatches)
		}
	}

	private func joinMatch(withId id: Match.ID) {
		if inMatch {
			showMatchInProgressWarning = true
		} else {
			if spectating {
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
			} else {
				showCreateMatchPrompt = true
			}
		}
	}

	private func startRefreshTimer() {
		refreshTimer?.invalidate()
		refreshTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { [weak self] _ in
			self?.actions.send(.loadMatches)
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
	func errorMessage(from error: Error) -> String {
		guard let matchError = error as? MatchRepositoryError else {
			return error.localizedDescription
		}

		switch matchError {
		case .usingOfflineAccount: return "You're currently playing offline"
		case .apiError(let apiError): return apiError.errorDescription ?? apiError.localizedDescription
		}
	}
}
