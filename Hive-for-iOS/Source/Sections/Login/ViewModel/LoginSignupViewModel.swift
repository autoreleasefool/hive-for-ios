//
//  LoginSignupViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-30.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine

enum LoginSignupViewAction: BaseViewAction {
	case loginSignup(LoginSignupData)
	case toggleMethod
	case focusedField(LoginFieldID)
}

enum LoginFieldID {
	case email
	case password
	case verifyPassword
	case displayName

	var title: String {
		switch self {
		case .email: return "Email"
		case .password: return "Password"
		case .verifyPassword: return "Confirm password"
		case .displayName: return "Display name"
		}
	}

	var isSecure: Bool {
		switch self {
		case .email, .displayName: return false
		case .password, .verifyPassword: return true
		}
	}
}

class LoginSignupViewModel: ViewModel<LoginSignupViewAction>, ObservableObject {
	@Published private(set) var loggingIn: Bool = true
	@Published private(set) var activeField: LoginFieldID? = .email

	override init() {
		super.init()
	}

	override func postViewAction(_ viewAction: LoginSignupViewAction) {
		switch viewAction {
		case .toggleMethod:
			loggingIn.toggle()
		case .loginSignup(let data):
			if loggingIn {
				performLogin(data.login)
			} else {
				performSignup(data.signup)
			}
		case .focusedField(let field):
			activeField = field
		}
	}

	func isActive(field: LoginFieldID) -> Binding<Bool> {
		Binding(
			get: { field == self.activeField },
			set: { newValue in self.activeField = newValue ? field : nil }
		)
	}

	private func performLogin(_ request: LoginData) {

	}

	private func performSignup(_ request: SignupData) {

	}
}
