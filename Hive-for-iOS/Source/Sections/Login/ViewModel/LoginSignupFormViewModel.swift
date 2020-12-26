//
//  LoginSignupFormViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import AuthenticationServices
import Combine
import UIKit

enum LoginSignupViewAction: BaseViewAction {
	case toggleForm
	case submitForm
	case dismissForm
	case playAsGuest
	case signInWithApple(Result<ASAuthorization, Error>)
}

enum LoginSignupAction: BaseAction {
	case login(User.Login.Request)
	case signup(User.Signup.Request)
	case signInWithApple(User.SignInWithApple.Request)
	case createGuestAccount
	case dismiss
	case showLoaf(LoafState)
}

class LoginSignupFormViewModel: ViewModel<LoginSignupViewAction>, ObservableObject {
	@Published var account: Loadable<AnyAccount>
	@Published var form: Form

	@Published var email: String = ""
	@Published var password: String = ""
	@Published var displayName: String = ""
	@Published var confirmPassword: String = ""

	private let actions = PassthroughSubject<LoginSignupAction, Never>()
	var actionsPublisher: AnyPublisher<LoginSignupAction, Never> {
		actions.eraseToAnyPublisher()
	}

	init(defaultForm: Form = .login, account: Loadable<AnyAccount> = .notLoaded) {
		self._account = .init(initialValue: account)
		self._form = .init(initialValue: defaultForm)
	}

	override func postViewAction(_ viewAction: LoginSignupViewAction) {
		switch viewAction {
		case .toggleForm:
			toggleForm()
		case .submitForm:
			submitForm()
		case .dismissForm:
			actions.send(.dismiss)
		case .playAsGuest:
			actions.send(.createGuestAccount)
		case .signInWithApple(let result):
			handleSignInWithApple(result)
		}
	}

	// MARK: Properties

	var shouldShowNotice: Bool {
		switch account {
		case .failed: return true
		case .loaded, .loading, .notLoaded: return false
		}
	}

	private func nextField(after id: FieldItem) -> FieldItem? {
		switch (id, form) {
		case (_, .signInWithApple): return nil

		case (.email, .login): return .password
		case (.email, .signup): return .displayName

		case (.displayName, .login): return .password
		case (.displayName, .signup): return .password

		case (.password, .login): return nil
		case (.password, .signup): return .confirmPassword

		case (.confirmPassword, .login): return nil
		case (.confirmPassword, .signup): return nil
		}
	}

	func shouldShow(field: FieldItem) -> Bool {
		switch (field, form) {
		case (.displayName, .signInWithApple): return true
		case (_, .signInWithApple): return false

		case (.email, .login): return true
		case (.email, .signup): return true

		case (.displayName, .login): return false
		case (.displayName, .signup): return true

		case (.password, .login): return true
		case (.password, .signup): return true

		case (.confirmPassword, .login): return false
		case (.confirmPassword, .signup): return true
		}
	}

	private var loginData: User.Login.Request {
		User.Login.Request(email: email.lowercased(), password: password)
	}

	private var signupData: User.Signup.Request {
		User.Signup.Request(
			email: email.lowercased(),
			displayName: displayName,
			password: password,
			verifyPassword: confirmPassword
		)
	}

	private var signInWithAppleData: User.SignInWithApple.Request {
		User.SignInWithApple.Request(
			appleIdentityToken: "",
			displayName: displayName,
			avatarUrl: nil
		)
	}

	private func toggleForm() {
		switch form {
		case .login: form = .signup
		case .signup: form = .login
		case .signInWithApple: break
		}
	}

	private func submitForm() {
		switch form {
		case .login: actions.send(.login(loginData))
		case .signup: actions.send(.signup(signupData))
		case .signInWithApple: break
		}
	}

	private func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
		guard case .success(let authorization) = result else {
			actions.send(.showLoaf(LoafState("Sign in with Apple failed", style: .error())))
			return
		}

		guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
					let identityToken = appleIDCredential.identityToken,
					let identityTokenString = String(data: identityToken, encoding: .utf8) else {
			actions.send(.showLoaf(LoafState("Invalid credentials", style: .error())))
			return
		}

		let displayName = self.displayName.trimmingCharacters(in: .whitespaces)
		guard displayName.count > 3 && displayName.count < 24 else {
			actions.send(.showLoaf(LoafState("Invalid display name", style: .error())))
			return
		}

		actions.send(
			.signInWithApple(
				User.SignInWithApple.Request(
					appleIdentityToken: identityTokenString,
					displayName: displayName,
					avatarUrl: nil
				)
			)
		)
	}
}

// MARK: - Form

extension LoginSignupFormViewModel {
	enum Form {
		case login
		case signup
		case signInWithApple
	}
}

// MARK: - FieldItem

extension LoginSignupFormViewModel {
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
			switch (self, form) {
			case (_, .signInWithApple): return .done

			case (.email, .login): return .next
			case (.email, .signup): return .next

			case (.displayName, .login): return .next
			case (.displayName, .signup): return .next

			case (.password, .login): return .done
			case (.password, .signup): return .next

			case (.confirmPassword, _): return .done
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

extension LoginSignupFormViewModel {
	var submitButtonText: String {
		switch form {
		case .login: return "Log in"
		case .signup: return "Sign up"
		case .signInWithApple: return "Sign in"
		}
	}

	var toggleSectionHeaderText: String? {
		switch form {
		case .login: return "Don't have an account?"
		case .signup: return "Already have an account?"
		case .signInWithApple: return nil
		}
	}

	var toggleButtonText: String? {
		switch form {
		case .login: return "Sign up"
		case .signup: return "Log in"
		case .signInWithApple: return nil
		}
	}

	var noticeMessage: String {
		switch account {
		case .failed(let error):
			if let accountError = error as? AccountRepositoryError {
				switch accountError {
				case .loggedOut: return "You've been logged out. Please log in again."
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
		case .usingOfflineAccount:
			return "You've chosen to play offline"
		case .unauthorized:
			return "You entered an incorrect email or password."
		case .networkingError:
			return "There was an error connecting to the server. Are you connected to the Internet?"
		case
			.invalidData,
			.invalidHTTPResponse,
			.invalidResponse,
			.missingData,
			.notImplemented,
			.invalidURL,
			.unsupported:
			return error.errorDescription ?? error.localizedDescription
		}
	}
}

extension LoginSignupFormViewModel.FieldItem {
	var title: String {
		switch self {
		case .email: return "Email"
		case .password: return "Password"
		case .confirmPassword: return "Confirm password"
		case .displayName: return "Display name"
		}
	}
}
