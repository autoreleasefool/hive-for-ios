//
//  ProfileListViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-10-21.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import HiveFoundation
import SwiftUI

enum ProfileListViewAction: BaseViewAction {
	case openSettings
	case reload
}

enum ProfileListAction: BaseAction {
	case openSettings
	case loadUsers(filter: String)
}

class ProfileListViewModel: ViewModel<ProfileListViewAction>, ObservableObject {
	@Published var searchText: String = ""
	@Published var users: Loadable<[User]>

	private let actions = PassthroughSubject<ProfileListAction, Never>()
	var actionsPublisher: AnyPublisher<ProfileListAction, Never> {
		actions.eraseToAnyPublisher()
	}

	init(users: Loadable<[User]>) {
		_users = .init(initialValue: users)
		super.init()

		$searchText
			.dropFirst()
			.debounce(for: .milliseconds(500), scheduler: RunLoop.main)
			.sink { [weak self] in self?.debounceSearch($0) }
			.store(in: self)
	}

	override func postViewAction(_ viewAction: ProfileListViewAction) {
		switch viewAction {
		case .openSettings:
			actions.send(.openSettings)
		case .reload:
			debounceSearch(searchText)
		}
	}

	private func debounceSearch(_ filter: String) {
		guard !filter.isEmpty else {
			users = .notLoaded
			return
		}

		actions.send(.loadUsers(filter: filter))
	}
}

// MARK: - Strings

extension ProfileListViewModel {
	func errorMessage(from error: Error) -> String {
		guard let userError = error as? UserRepositoryError else {
			return error.localizedDescription
		}

		switch userError {
		case .missingID: return "Account missing"
		case .apiError(let apiError): return apiError.localizedDescription
		case .usingOfflineAccount: return "You're offline"
		}
	}
}
