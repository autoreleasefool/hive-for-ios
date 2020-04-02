//
//  LoginSignupViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-30.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine
import Foundation

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
	@Published private(set) var validatingAccount: Bool = false
	@Published private(set) var validationFailed: Bool = false
	@Published private(set) var loggingIn: Bool = true
	@Published private(set) var activeField: LoginFieldID?

	private var account: Account!

	private(set) var didSuccessfullyAuthenticate = PassthroughSubject<Void, Never>()

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
		HiveAPI
			.shared
			.login(login: request)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						#warning("TODO: do something with the error")
					}
				},
				receiveValue: { [weak self] token in
					self?.handle(accessToken: token)
				}
			)
			.store(in: self)
	}

	private func performSignup(_ request: SignupData) {
		HiveAPI
			.shared
			.signup(signup: request)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						#warning("TODO: do something with the error")
					}
				},
				receiveValue: { [weak self] userSignup in
					self?.handle(accessToken: userSignup.accessToken)
				}
			)
			.store(in: self)
	}

	private func handle(accessToken: AccessToken) {
		do {
			try account.store(accessToken: accessToken)
			self.didSuccessfullyAuthenticate.send()
		} catch {
			#warning("TODO: do something with the error")
		}
	}

	func update(account: Account) {
		self.account = account
		guard let userID = account.userId, let accessToken = account.accessToken else { return }
		validatingAccount = true
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			self.didSuccessfullyAuthenticate.send()
		}
	}
}
