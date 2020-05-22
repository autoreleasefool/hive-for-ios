//
//  LoginSignupViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import UIKit

enum LoginSignupViewAction: BaseViewAction {
	case toggleForm
	case submitForm
	case focusField(LoginSignupViewModel.FieldItem)
	case didReturn(from: LoginSignupViewModel.FieldItem)
}

enum LoginSignupAction: BaseAction {
	case login(LoginData)
	case signup(SignupData)
}

class LoginSignupViewModel: ViewModel<LoginSignupViewAction>, ObservableObject {
	@Published var account: Loadable<Account>
	@Published var form: Form
	@Published var activeField: FieldItem?

	@Published var email: String = ""
	@Published var password: String = ""
	@Published var displayName: String = ""
	@Published var confirmPassword: String = ""

	private let actions = PassthroughSubject<LoginSignupAction, Never>()
	var actionsPublisher: AnyPublisher<LoginSignupAction, Never> {
		actions.eraseToAnyPublisher()
	}

	init(defaultForm: Form = .login, account: Loadable<Account> = .notLoaded) {
		self._account = .init(initialValue: account)
		self._form = .init(initialValue: defaultForm)
	}

	override func postViewAction(_ viewAction: LoginSignupViewAction) {
		switch viewAction {
		case .toggleForm:
			toggleForm()
		case .submitForm:
			submitForm()
		case .didReturn(let from):
			handleReturn(from: from)
		case .focusField(let id):
			activeField = id
		}
	}

	// MARK: Properties

	var shouldShowNotice: Bool {
		switch account {
		case .failed: return true
		case .loaded, .loading, .notLoaded: return false
		}
	}

	// MARK: Actions

	private func handleReturn(from id: FieldItem) {
		if let field = nextField(after: id) {
			activeField = field
		} else {
			activeField = nil
			submitForm()
		}
	}

	private func nextField(after id: FieldItem) -> FieldItem? {
		switch id {
		case .email: return form == .login ? .password : .displayName
		case .displayName: return .password
		case .password: return form == .login ? nil : .confirmPassword
		case .confirmPassword: return nil
		}
	}

	private var loginData: LoginData {
		LoginData(email: email.lowercased(), password: password)
	}

	private var signupData: SignupData {
		SignupData(
			email: email.lowercased(),
			displayName: displayName,
			password: password,
			verifyPassword: confirmPassword
		)
	}

	private func toggleForm() {
		form = form == .login ? .signup : .login
	}

	private func submitForm() {
		activeField = nil
		switch form {
		case .login: actions.send(.login(loginData))
		case .signup: actions.send(.signup(signupData))
		}
	}
}

// MARK: - Form

extension LoginSignupViewModel {
	enum Form {
		case login
		case signup
	}
}

// MARK: - FieldItem

extension LoginSignupViewModel {
	enum FieldItem {
		case email
		case password
		case confirmPassword
		case displayName

		var isSecure: Bool {
			switch self {
			case .email, .displayName: return false
			case .password, .confirmPassword: return true
			}
		}

		var keyboardType: UIKeyboardType {
			switch self {
			case .email: return .emailAddress
			case .confirmPassword, .password, .displayName: return .default
			}
		}

		var textContentType: UITextContentType {
			switch self {
			case .email: return .emailAddress
			case .password, .confirmPassword: return .password
			case .displayName: return .username
			}
		}

		func returnKeyType(forForm form: Form) -> UIReturnKeyType {
			switch self {
			case .email, .displayName: return .next
			case .confirmPassword: return .done
			case .password: return form == .login ? .done : .next
			}
		}

		var maxLength: Int? {
			switch self {
			case .displayName: return 24
			case .email, .password, .confirmPassword: return nil
			}
		}
	}
}

// MARK: - Strings

extension LoginSignupViewModel {
	var submitButtonText: String {
		switch form {
		case .login: return "Login"
		case .signup: return "Signup"
		}
	}

	var toggleButtonText: String {
		switch form {
		case .login: return "create a new account"
		case .signup: return "login to an existing account"
		}
	}

	var noticeMessage: String {
		switch account {
		case .failed(let error):
			if let accountError = error as? AccountRepositoryError {
				switch accountError {
				case .loggedOut: return "You've been logged out. Please login again."
				case .apiError(let apiError): return noticeMessage(for: apiError)
				case .notFound, .keychainError: return ""
				}
			}
			return error.localizedDescription
		case .loaded, .loading, .notLoaded: return ""
		}
	}

	func noticeMessage(for error: HiveAPIError) -> String {
		switch error {
		case .unauthorized:
			return "You entered an incorrect email or password."
		case .networkingError:
			return "There was an error connecting to the server. Are you connected to the Internet?"
		case .invalidData, .invalidHTTPResponse, .invalidResponse, .missingData, .notImplemented:
			return error.errorDescription ?? error.localizedDescription
		}
	}
}

extension LoginSignupViewModel.FieldItem {
	var title: String {
		switch self {
		case .email: return "Email"
		case .password: return "Password"
		case .confirmPassword: return "Confirm password"
		case .displayName: return "Display name"
		}
	}
}
