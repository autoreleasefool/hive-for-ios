//
//  LoginSignup.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-02.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

struct LoginSignup: View {
	@Environment(\.container) private var container: AppContainer

	@State private var account: Loadable<Account>
	@State private var form: Form
	@State private var activeField: FieldItem?

	@State private var email: String = ""
	@State private var password: String = ""
	@State private var confirmPassword: String = ""
	@State private var displayName: String = ""

	init(defaultForm: Form = .login, account: Loadable<Account> = .notLoaded) {
		self._account = .init(initialValue: account)
		self._form = .init(initialValue: defaultForm)
	}

	var body: some View {
		content
			.padding(.all, length: .m)
			.avoidingKeyboard()
	}

	private var content: AnyView {
		switch account {
		case .notLoaded, .failed: return AnyView(formView)
		case .loading, .loaded: return AnyView(loadingView)
		}
	}

	// MARK: Content

	private var formView: some View {
		ScrollView {
			VStack(spacing: .m) {
				if shouldShowNotice {
					notice(message: noticeMessage)
				}

				field(for: .email)
				if form == .signup {
					field(for: .displayName)
				}
				field(for: .password)
				if form == .signup {
					field(for: .confirmPassword)
				}

				submitButton
				toggleButton
			}
		}
	}

	private var loadingView: some View {
		GeometryReader { geometry in
			HStack {
				Spacer()
				ActivityIndicator(isAnimating: true, style: .whiteLarge)
				Spacer()
			}
			.padding(.top, length: .m)
			.frame(width: geometry.size.width)
		}
	}

	// MARK: Form

	private func text(for id: FieldItem) -> Binding<String> {
		switch id {
		case .email: return $email
		case .password: return $password
		case .confirmPassword: return $confirmPassword
		case .displayName: return $displayName
		}
	}

	private func field(for id: FieldItem) -> some View {
		LoginField(
			id.title,
			text: text(for: id),
			maxLength: id.maxLength,
			keyboardType: id.keyboardType,
			returnKeyType: id.returnKeyType(forForm: form),
			isActive: activeField == id,
			isSecure: id.isSecure,
			onReturn: { self.handleReturn(from: id) }
		)
		.frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
		.onTapGesture {
			self.activeField = id
		}
	}

	private var submitButton: some View {
		Button(action: {
			self.submitForm()
		}, label: {
			Text(submitButtonText)
				.body()
				.foregroundColor(Color(.background))
				.padding(.vertical, length: .m)
				.frame(minWidth: 0, maxWidth: .infinity)
				.background(
					RoundedRectangle(cornerRadius: .s)
						.fill(Color(.actionSheetBackground))
				)
		})
	}

	private var toggleButton: some View {
		HStack(spacing: 0) {
			Text("or ")
				.caption()
				.foregroundColor(Color(.text))
			Button(action: {
				self.toggleForm()
			}, label: {
				Text(toggleButtonText)
					.caption()
					.foregroundColor(Color(.primary))
					.padding(.vertical, length: .s)
			})
		}
	}

	private func notice(message: String) -> some View {
		Text(message)
			.body()
			.foregroundColor(Color(.highlight))
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
	}
}

// MARK: - Actions

extension LoginSignup {
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
			activeField = field
		} else {
			activeField = nil
			submitForm()
		}
	}

	private func toggleForm() {
		form = form == .login ? .signup : .login
	}

	private func submitForm() {
		activeField = nil
		switch form {
		case .login: login()
		case .signup: signup()
		}
	}

	private func login() {
		container.interactors.accountInteractor
			.login(loginData, account: $account)
	}

	private func signup() {
		container.interactors.accountInteractor
			.signup(signupData, account: $account)
	}
}

// MARK: - Form

extension LoginSignup {
	enum Form {
		case login
		case signup
	}
}

// MARK: - FieldItem

extension LoginSignup {
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

		func returnKeyType(forForm form: LoginSignup.Form) -> UIReturnKeyType {
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

extension LoginSignup {
	private var submitButtonText: String {
		switch form {
		case .login: return "Login"
		case .signup: return "Signup"
		}
	}

	private var toggleButtonText: String {
		switch form {
		case .login: return "create a new account"
		case .signup: return "login to an existing account"
		}
	}

	private var shouldShowNotice: Bool {
		switch account {
		case .failed: return true
		case .loaded, .loading, .notLoaded: return false
		}
	}

	private var noticeMessage: String {
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

	private func noticeMessage(for error: HiveAPIError) -> String {
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

extension LoginSignup.FieldItem {
	var title: String {
		switch self {
		case .email: return "Email"
		case .password: return "Password"
		case .confirmPassword: return "Confirm password"
		case .displayName: return "Display name"
		}
	}
}

#if DEBUG
struct LoginSignupPreview: PreviewProvider {
	static var previews: some View {
		VStack(spacing: .m) {
			LoginSignup(defaultForm: .login)
			LoginSignup(defaultForm: .signup)
		}
		.background(Color(.background))
	}
}
#endif
