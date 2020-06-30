//
//  HistoryViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine

enum HistoryViewAction: BaseViewAction {
	case onAppear
	case openSettings
}

enum HistoryAction: BaseAction {
	case loadMatchHistory
}

class HistoryViewModel: ViewModel<HistoryViewAction>, ObservableObject {
	@Published var settingsOpened = false

	private let actions = PassthroughSubject<HistoryAction, Never>()
	var actionsPublisher: AnyPublisher<HistoryAction, Never> {
		actions.eraseToAnyPublisher()
	}

	override func postViewAction(_ viewAction: HistoryViewAction) {
		switch viewAction {
		case .onAppear:
			actions.send(.loadMatchHistory)
		case .openSettings:
			settingsOpened = true
		}
	}

	func matches(for section: History.ListSection, fromUser user: User?) -> [Match] {
		switch section {
		case .inProgress: return user?.activeMatches ?? []
		case .completed: return user?.pastMatches ?? []
		}
	}
}

// MARK: - Strings

extension HistoryViewModel {
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

extension History.ListSection {
	var headerText: String {
		switch self {
		case .inProgress: return "Matches in progress"
		case .completed: return "Past matches"
		}
	}
}
