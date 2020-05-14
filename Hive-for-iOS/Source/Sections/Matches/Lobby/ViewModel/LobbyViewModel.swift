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
	case openSettings
	case joinMatch(Match.ID)
	case createNewMatch
	case refresh
}

enum LobbyAction: BaseAction {
	case loadOpenMatches
	case openSettings
	case joinMatch(Match.ID)
	case createNewMatch
	case leaveMatch
}

class LobbyViewModel: ViewModel<LobbyViewAction>, ObservableObject {

	@Published var matches: Loadable<[Match]>
	@Published var routing = Lobby.Routing()

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
			actions.send(.openSettings)
		case .createNewMatch:
			actions.send(.createNewMatch)
		case .joinMatch(let id):
			actions.send(.joinMatch(id))
		}
	}

	var inRoom: Binding<Bool> {
		Binding(
			get: { [weak self] in
				guard let self = self else { return false }
				return !self.routing.creatingRoom && self.routing.matchId != nil
			},
			set: { [weak self] newValue in
				guard !newValue else { return }
				self?.actions.send(.leaveMatch)
			}
		)
	}

	var creatingRoom: Binding<Bool> {
		Binding(
			get: { [weak self] in
				self?.routing.creatingRoom ?? false
			},
			set: { [weak self] newValue in
				guard !newValue else { return }
				self?.actions.send(.leaveMatch)
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
