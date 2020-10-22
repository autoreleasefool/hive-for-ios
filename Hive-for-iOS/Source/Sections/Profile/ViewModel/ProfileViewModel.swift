//
//  ProfileViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine

enum ProfileViewAction: BaseViewAction {
	case onAppear
	case loadProfile
}

enum ProfileAction: BaseAction {
	case loadProfile
}

class ProfileViewModel: ViewModel<ProfileViewAction>, ObservableObject {
	let id: User.ID?
	@Published var user: Loadable<User>

	private let actions = PassthroughSubject<ProfileAction, Never>()
	var actionsPublisher: AnyPublisher<ProfileAction, Never> {
		actions.eraseToAnyPublisher()
	}

	init(id: User.ID?, user: Loadable<User>) {
		self.id = id
		_user = .init(initialValue: user)
	}

	override func postViewAction(_ viewAction: ProfileViewAction) {
		switch viewAction {
		case .onAppear:
			actions.send(.loadProfile)
		case .loadProfile:
			actions.send(.loadProfile)
		}
	}
}

// MARK: - Strings

extension ProfileViewModel {
	var title: String {
		user.value?.displayName ?? ""
	}

	var isTitleEnabled: Bool {
		id != nil
	}

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
