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
import Loaf

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
	@Published private(set) var activeField: LoginFieldID?

	private(set) var error = PassthroughSubject<LoafState, Never>()

	var account: Account?
	var api: HiveAPI?

	private(set) var didSuccessfullyAuthenticate = PassthroughSubject<Void, Never>()

	override func postViewAction(_ viewAction: LoginSignupViewAction) {
		switch viewAction {
		case .toggleMethod:
			loggingIn.toggle()
		case .loginSignup(let data):
			LoadingHUD.shared.show()
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
			get: { [weak self] in field == self?.activeField },
			set: { [weak self] newValue in self?.activeField = newValue ? field : nil }
		)
	}

	private func performLogin(_ request: LoginData) {
		api?.login(login: request)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						self?.error.send(error.loaf)
					}
					LoadingHUD.shared.hide()
				},
				receiveValue: { [weak self] token in
					self?.handle(accessToken: token)
				}
			)
			.store(in: self)
	}

	private func performSignup(_ request: SignupData) {
		api?.signup(signup: request)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						self?.error.send(error.loaf)
					}
					LoadingHUD.shared.hide()
				},
				receiveValue: { [weak self] userSignup in
					self?.handle(accessToken: userSignup.accessToken)
				}
			)
			.store(in: self)
	}

	private func handle(accessToken: AccessToken) {
		do {
			try account?.store(accessToken: accessToken)
			didSuccessfullyAuthenticate.send()
		} catch {
			self.error.send(LoafState(error.localizedDescription, state: .error))
		}
	}
}
