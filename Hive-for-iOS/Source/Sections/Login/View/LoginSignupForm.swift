//
//  LoginSignupForm.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-02.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

struct LoginSignupForm: View {
	@Environment(\.container) private var container
	@ObservedObject private var viewModel: LoginSignupFormViewModel

	init(
		defaultForm: LoginSignupFormViewModel.Form = .login,
		account: Loadable<Account> = .notLoaded,
		onCancel: (() -> Void)? = nil) {
		viewModel = LoginSignupFormViewModel(defaultForm: defaultForm, account: account, onCancel: onCancel)
	}

	var body: some View {
		content
			.onReceive(viewModel.actionsPublisher) { handleAction($0) }
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.account {
		case .notLoaded, .failed: formView
		case .loading, .loaded: loadingView
		}
	}

	// MARK: Content

	private var formView: some View {
		Form {
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

			VStack(alignment: .center) {
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
			.frame(width: geometry.size.width)
		}
	}

	// MARK: Form

	private func secureField(for id: LoginSignupFormViewModel.FieldItem) -> some View {
		SecureField(id.title, text: text(for: id))
			.modifier(LoginFieldAppearance(id: id))
	}

	private func field(for id: LoginSignupFormViewModel.FieldItem) -> some View {
		TextField(id.title, text: text(for: id))
			.modifier(LoginFieldAppearance(id: id))
	}

	private func text(for id: LoginSignupFormViewModel.FieldItem) -> Binding<String> {
		switch id {
		case .email: return $viewModel.email
		case .password: return $viewModel.password
		case .confirmPassword: return $viewModel.confirmPassword
		case .displayName: return $viewModel.displayName
		}
	}

	private var submitButton: some View {
		PrimaryButton(viewModel.submitButtonText) {
			viewModel.postViewAction(.submitForm)
		}
	}

	private var toggleButton: some View {
		HStack(spacing: 0) {
			Text("you can also ")
				.font(.caption)
			Button {
				viewModel.postViewAction(.toggleForm)
			} label: {
				Text(viewModel.toggleButtonText)
					.font(.caption)
					.foregroundColor(Color(.highlightPrimary))
			}
		}
		.padding(.top)
	}

	private var cancelButton: some View {
		HStack(spacing: 0) {
			Text("or")
				.font(.caption)
			Button {
				viewModel.postViewAction(.exitForm)
			} label: {
				Text(" exit ")
					.font(.caption)
					.foregroundColor(Color(.highlightPrimary))
			}
			Text("to main menu")
				.font(.caption)
		}
		.padding(.top)
	}

	private func notice(message: String) -> some View {
		Text(message)
			.font(.body)
			.foregroundColor(Color(.highlightRegular))
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
	}
}

// MARK: - Actions

extension LoginSignupForm {
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

private extension LoginSignupForm {
	struct LoginFieldAppearance: ViewModifier {
		let id: LoginSignupFormViewModel.FieldItem

		func body(content: Content) -> some View {
			content
				.textContentType(id.textContentType)
				.keyboardType(id.keyboardType)
				.foregroundColor(Color(.textRegular))
				.padding()
		}
	}
}

// MARK: - Preview

#if DEBUG
struct LoginSignupPreview: PreviewProvider {
	static var previews: some View {
		VStack(spacing: .m) {
			LoginSignupForm(defaultForm: .login)
			LoginSignupForm(defaultForm: .signup)
		}
//		.background(Color(.backgroundRegular).edgesIgnoringSafeArea(.all))
	}
}
#endif
