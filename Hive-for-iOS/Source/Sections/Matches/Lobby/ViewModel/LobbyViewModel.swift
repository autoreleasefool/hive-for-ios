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
	case leaveMatch
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
		case .leaveMatch:
			actions.send(.leaveMatch)
		}
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
