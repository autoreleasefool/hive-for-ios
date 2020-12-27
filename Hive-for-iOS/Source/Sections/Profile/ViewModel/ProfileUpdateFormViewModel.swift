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
	private static let fieldErrorKeys = [
		"displayName": "Display name",
	]

	@Published var user: Loadable<User>

	@Published var displayName: String = ""

	@Published var error: String?

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

// MARK: - Errors

extension ProfileUpdateFormViewModel {
	var fieldError: String? {
		guard case .failed(let userError as UserRepositoryError) = user,
					case .apiError(let apiError) = userError,
					case .invalidHTTPResponse(let code, let apiMessage) = apiError,
					let message = apiMessage,
					code == 400 else {
			return nil
		}

		for (key, field) in Self.fieldErrorKeys {
			if message.contains(key) {
				return message.replacingOccurrences(of: key, with: field)
			}
		}

		return nil
	}

	var errorMessage: String? {
		guard fieldError == nil else { return nil }

		switch user {
		case .failed(let error as UserRepositoryError):
			switch error {
			case .apiError(let error): return errorMessage(for: error)
			case .usingOfflineAccount: return "You're currently offline"
			case .missingID: return nil
			}
		case .failed(let error):
			return error.localizedDescription
		case .loaded, .loading, .notLoaded: return nil
		}
	}

	private func errorMessage(for error: HiveAPIError) -> String {
		switch error {
		case .usingOfflineAccount:
			return "You've chosen to play offline"
		case .unauthorized:
			return "You entered an incorrect email or password."
		case .networkingError:
			return "There was an error connecting to the server. Are you connected to the Internet?"
		case
			.invalidData,
			.invalidResponse,
			.invalidHTTPResponse,
			.missingData,
			.notImplemented,
			.invalidURL,
			.unsupported:
			return error.errorDescription ?? error.localizedDescription
		}
	}
}

// MARK: - State

extension ProfileUpdateFormViewModel {
	struct State {
		let message: String?
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
