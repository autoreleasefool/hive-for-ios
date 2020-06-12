//
//  LobbyViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

enum LobbyViewAction: BaseViewAction {
	case onAppear
	case refresh
	case openSettings

	case joinMatch(Match.ID)
	case createNewMatch
	case createOnlineMatchVsPlayer
	case createLocalMatchVsComputer
	case cancelCreateMatch
}

enum LobbyAction: BaseAction {
	case loadOpenMatches
}

class LobbyViewModel: ViewModel<LobbyViewAction>, ObservableObject {

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

	@Published var matches: Loadable<[Match]>
	@Published var settingsOpened = false
	@Published var showMatchInProgressWarning = false
	@Published var showCreateMatchPrompt = false

	private let actions = PassthroughSubject<LobbyAction, Never>()
	var actionsPublisher: AnyPublisher<LobbyAction, Never> {
		actions.eraseToAnyPublisher()
	}

	init(matches: Loadable<[Match]>) {
		self._matches = .init(initialValue: matches)
	}

	override func postViewAction(_ viewAction: LobbyViewAction) {
		switch viewAction {
		case .onAppear, .refresh:
			actions.send(.loadOpenMatches)
		case .openSettings:
			settingsOpened = true

		case .createNewMatch:
			if inMatch {
				showMatchInProgressWarning = true
			} else {
				showCreateMatchPrompt = true
			}
		case .joinMatch(let id):
			if inMatch {
				showMatchInProgressWarning = true
			} else {
				currentMatchId = id
			}
		case .createOnlineMatchVsPlayer:
			creatingOnlineRoom = true
			showCreateMatchPrompt = false
		case .createLocalMatchVsComputer:
			creatingLocalRoom = true
			showCreateMatchPrompt = false
		case .cancelCreateMatch:
			showCreateMatchPrompt = false
		}
	}
}

extension LobbyViewModel {
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
}

// MARK: - Strings

extension LobbyViewModel {
	func errorMessage(from error: Error) -> String {
		guard let matchError = error as? MatchRepositoryError else {
			return error.localizedDescription
		}

		switch matchError {
		case .apiError(let apiError): return apiError.errorDescription ?? apiError.localizedDescription
		}
	}
}
