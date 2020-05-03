//
//  LoginSignupViewModelV2.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-02.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import UIKit

enum LoginSignupViewActionV2: BaseViewAction {
	case submit
	case toggleForm
	case focusField(LoginSignupViewModelV2.FieldItem)
	case fieldDidReturn(LoginSignupViewModelV2.FieldItem)
}

class LoginSignupViewModelV2: ViewModel<LoginSignupViewActionV2>, ObservableObject {
	enum Form {
		case login
		case signup
	}

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

		func returnKeyType(forForm form: Form) -> UIReturnKeyType {
			switch self {
			case .email, .displayName: return .next
			case .confirmPassword: return .done
			case .password: return form == .login ? .done : .next
			}
		}
	}

	@Published private(set) var form: Form = .login
	@Published private(set) var activeField: FieldItem = .email
	@Published var account: Loadable<AccountV2> = .notLoaded

	@Published var email: String = ""
	@Published var password: String = ""
	@Published var confirmPassword: String = ""
	@Published var displayName: String = ""

	private(set) var loginSubject = PassthroughSubject<LoginData, Never>()
	private(set) var signupSubject = PassthroughSubject<SignupData, Never>()

	var loginData: LoginData {
		LoginData(email: email, password: password)
	}

	var signupData: SignupData {
		SignupData(email: email, displayName: displayName, password: password, verifyPassword: confirmPassword)
	}

	override func postViewAction(_ viewAction: LoginSignupViewActionV2) {
		switch viewAction {
		case .submit:
			submitForm()
		case .toggleForm:
			form = form == .login ? .signup : .login
		case .focusField(let id):
			activeField = id
		case .fieldDidReturn(let id):
			handleReturn(from: id)
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

	private func handleReturn(from id: FieldItem) {
		if let field = nextField(after: id) {
			postViewAction(.focusField(field))
		} else {
			submitForm()
		}
	}

	private func submitForm() {
		switch form {
		case .login: loginSubject.send(loginData)
		case .signup: signupSubject.send(signupData)
		}
	}
}

// MARK: - Strings

extension LoginSignupViewModelV2 {
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

	var shouldShowNotice: Bool {
		switch account {
		case .failed: return true
		case .loaded, .loading, .notLoaded: return false
		}
	}

	var noticeMessage: String {
		switch account {
		case .failed(let error):
			if let accountError = error as? AccountRepositoryError {
				switch accountError {
				case .loggedOut: return "You've been logged out. Please login again."
				case .apiError(let apiError): return apiError.errorDescription ?? error.localizedDescription
				case .notFound, .keychainError: return ""
				}
			}
			return error.localizedDescription
		case .loaded, .loading, .notLoaded: return ""
		}
	}
}

extension LoginSignupViewModelV2.FieldItem {
	var title: String {
		switch self {
		case .email: return "Email"
		case .password: return "Password"
		case .confirmPassword: return "Confirm password"
		case .displayName: return "Display name"
		}
	}
}
