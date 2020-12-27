//
//  ProfileUpdateFormViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-12-26.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import UIKit

enum ProfileUpdateViewAction: BaseViewAction {
	case submitForm
	case dismissForm
}

enum ProfileUpdateAction: BaseAction {
	case updateProfile(User.Update.Request)
	case dismiss
}

class ProfileUpdateFormViewModel: ViewModel<ProfileUpdateViewAction>, ObservableObject {
	@Published var user: Loadable<User>

	@Published var displayName: String = ""

	let state: State

	private let actions = PassthroughSubject<ProfileUpdateAction, Never>()
	var actionsPublisher: AnyPublisher<ProfileUpdateAction, Never> {
		actions.eraseToAnyPublisher()
	}

	init(state: State, user: Loadable<User> = .notLoaded) {
		self.state = state
		self._user = .init(initialValue: user)
	}

	override func postViewAction(_ viewAction: ProfileUpdateViewAction) {
		switch viewAction {
		case .submitForm:
			submit()
		case .dismissForm:
			dismiss()
		}
	}

	private func submit() {
		let trimDisplayName = displayName.trimmingCharacters(in: .whitespaces)
		let displayName = trimDisplayName.isEmpty ? nil : trimDisplayName

		actions.send(
			.updateProfile(
				User.Update.Request(
					displayName: displayName,
					avatarUrl: nil
				)
			)
		)
	}

	private func dismiss() {
		guard !state.isRequired else { return }
		actions.send(.dismiss)
	}
}

// MARK: - FieldItem

extension ProfileUpdateFormViewModel {
	enum FieldItem {
		case displayName

		var title: String {
			switch self {
			case .displayName: return "Display name"
			}
		}

		var textContentType: UITextContentType {
			switch self {
			case .displayName: return .username
			}
		}

		var keyboardType: UIKeyboardType {
			switch self {
			case .displayName: return .default
			}
		}
	}
}

// MARK: - State

extension ProfileUpdateFormViewModel {
	struct State {
		let message: String
		let fields: Set<FieldItem>
		let isRequired: Bool

		static var newAppleAccount: State {
			State(
				message: "To finish creating your account, please choose a name other users can find you by",
				fields: [.displayName],
				isRequired: true
			)
		}
	}
}
