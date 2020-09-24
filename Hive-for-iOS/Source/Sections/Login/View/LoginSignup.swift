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
	@Environment(\.container) private var container
	@ObservedObject private var viewModel: LoginSignupViewModel

	init(
		defaultForm: LoginSignupViewModel.Form = .login,
		account: Loadable<Account> = .notLoaded,
		onCancel: (() -> Void)? = nil) {
		viewModel = LoginSignupViewModel(defaultForm: defaultForm, account: account, onCancel: onCancel)
	}

	var body: some View {
		content
			.padding(.all, length: .m)
			.onReceive(viewModel.actionsPublisher) { self.handleAction($0) }
	}

	private var content: AnyView {
		switch viewModel.account {
		case .notLoaded, .failed: return AnyView(formView)
		case .loading, .loaded: return AnyView(loadingView)
		}
	}

	// MARK: Content

	private var formView: some View {
		ScrollView {
			VStack(spacing: .m) {
				if viewModel.shouldShowNotice {
					notice(message: viewModel.noticeMessage)
				}

				field(for: .email)
				if viewModel.form == .signup {
					field(for: .displayName)
				}
				secureField(for: .password)
				if viewModel.form == .signup {
					secureField(for: .confirmPassword)
				}

				submitButton
				toggleButton
				cancelButton
			}
		}
	}

	private var loadingView: some View {
		GeometryReader { geometry in
			HStack {
				Spacer()
				ActivityIndicator(isAnimating: true, style: .large)
				Spacer()
			}
			.padding(.top, length: .m)
			.frame(width: geometry.size.width)
		}
	}

	// MARK: Form

	private func secureField(for id: LoginSignupViewModel.FieldItem) -> some View {
		SecureField(id.title, text: text(for: id))
			.modifier(LoginFieldAppearance(id: id))
	}

	private func field(for id: LoginSignupViewModel.FieldItem) -> some View {
		TextField(id.title, text: text(for: id))
			.modifier(LoginFieldAppearance(id: id))
	}

	private func text(for id: LoginSignupViewModel.FieldItem) -> Binding<String> {
		switch id {
		case .email: return $viewModel.email
		case .password: return $viewModel.password
		case .confirmPassword: return $viewModel.confirmPassword
		case .displayName: return $viewModel.displayName
		}
	}

	private var submitButton: some View {
		BasicButton<Never>(viewModel.submitButtonText) {
			self.viewModel.postViewAction(.submitForm)
		}
	}

	private var toggleButton: some View {
		HStack(spacing: 0) {
			Text("you can also ")
				.caption()
				.foregroundColor(Color(.textRegular))
			Button(action: {
				self.viewModel.postViewAction(.toggleForm)
			}, label: {
				Text(viewModel.toggleButtonText)
					.caption()
					.foregroundColor(Color(.highlightPrimary))
			})
		}
		.padding(.top, length: .s)
		.padding(.bottom, length: .xs)
	}

	private var cancelButton: some View {
		HStack(spacing: 0) {
			Text("or")
				.caption()
				.foregroundColor(Color(.textRegular))
			Button(action: {
				self.viewModel.postViewAction(.exitForm)
			}, label: {
				Text(" exit ")
					.caption()
					.foregroundColor(Color(.highlightPrimary))
			})
			Text("to main menu")
				.caption()
				.foregroundColor(Color(.textRegular))
		}
		.padding(.top, length: .xs)
		.padding(.bottom, length: .s)
	}

	private func notice(message: String) -> some View {
		Text(message)
			.body()
			.foregroundColor(Color(.highlightRegular))
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
	}
}

// MARK: - Actions

extension LoginSignup {
	private func handleAction(_ action: LoginSignupAction) {
		switch action {
		case .login(let data):
			login(data)
		case .signup(let data):
			signup(data)
		}
	}

	private func login(_ data: User.Login.Request) {
		container.interactors.accountInteractor
			.login(data, account: $viewModel.account)
	}

	private func signup(_ data: User.Signup.Request) {
		container.interactors.accountInteractor
			.signup(data, account: $viewModel.account)
	}
}

// MARK: Login Field Modifier

private extension LoginSignup {
	struct LoginFieldAppearance: ViewModifier {
		let id: LoginSignupViewModel.FieldItem

		func body(content: Content) -> some View {
			content
				.textContentType(id.textContentType)
				.keyboardType(id.keyboardType)
				.foregroundColor(Color(.textRegular))
				.padding(.all, length: .m)
				.frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
				.overlay(
					RoundedRectangle(cornerRadius: .s)
						.stroke(Color(.textRegular), lineWidth: 1)
				)
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
		.background(Color(.backgroundRegular).edgesIgnoringSafeArea(.all))
	}
}
#endif
