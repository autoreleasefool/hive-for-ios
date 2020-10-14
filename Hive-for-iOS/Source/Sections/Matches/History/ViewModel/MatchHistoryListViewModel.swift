//
//  MatchHistoryListViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine

enum MatchHistoryListViewAction: BaseViewAction {
	case onAppear
	case openSettings
	case loadMatchHistory
}

enum MatchHistoryListAction: BaseAction {
	case loadMatchHistory
	case openSettings
}

class MatchHistoryListViewModel: ViewModel<MatchHistoryListViewAction>, ObservableObject {

	private let actions = PassthroughSubject<MatchHistoryListAction, Never>()
	var actionsPublisher: AnyPublisher<MatchHistoryListAction, Never> {
		actions.eraseToAnyPublisher()
	}

	override func postViewAction(_ viewAction: MatchHistoryListViewAction) {
		switch viewAction {
		case .onAppear:
			actions.send(.loadMatchHistory)
		case .openSettings:
			actions.send(.openSettings)
		case .loadMatchHistory:
			actions.send(.loadMatchHistory)
		}
	}

	func matches(for section: MatchHistoryList.ListSection, fromUser user: User?) -> [Match] {
		switch section {
		case .inProgress: return user?.activeMatches ?? []
		case .completed: return user?.pastMatches ?? []
		}
	}
}

// MARK: - Strings

extension MatchHistoryListViewModel {
	func errorMessage(from error: Error) -> String {
		guard let userError = error as? UserRepositoryError else {
			return error.localizedDescription
		}

		switch userError {
		case .missingID: return "Account not available"
		case .apiError(let apiError): return apiError.errorDescription ?? apiError.localizedDescription
		case .usingOfflineAccount: return "You're currently playing offline"
		}
	}
}

extension MatchHistoryList.ListSection {
	var headerText: String {
		switch self {
		case .inProgress: return "Matches in progress"
		case .completed: return "Past matches"
		}
	}
}
