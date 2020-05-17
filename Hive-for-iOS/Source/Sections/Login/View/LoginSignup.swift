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
	@ObservedObject private var viewModel: LoginSignupViewModel

	init(defaultForm: LoginSignupViewModel.Form = .login, account: Loadable<Account> = .notLoaded) {
		viewModel = LoginSignupViewModel(defaultForm: defaultForm, account: account)
	}

	var body: some View {
		content
			.padding(.all, length: .m)
			.avoidingKeyboard()
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
				field(for: .password)
				if viewModel.form == .signup {
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

	private func field(for id: LoginSignupViewModel.FieldItem) -> some View {
		LoginField(
			id.title,
			text: text(for: id),
			maxLength: id.maxLength,
			keyboardType: id.keyboardType,
			returnKeyType: id.returnKeyType(forForm: viewModel.form),
			isActive: viewModel.activeField == id,
			isSecure: id.isSecure,
			onReturn: { self.viewModel.postViewAction(.didReturn(from: id)) }
		)
		.frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
		.onTapGesture {
			self.viewModel.postViewAction(.focusField(id))
		}
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
		Button(action: {
			self.viewModel.postViewAction(.submitForm)
		}, label: {
			Text(viewModel.submitButtonText)
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
				self.viewModel.postViewAction(.toggleForm)
			}, label: {
				Text(viewModel.toggleButtonText)
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
	private func handleAction(_ action: LoginSignupAction) {
		switch action {
		case .login(let data):
			login(data)
		case .signup(let data):
			signup(data)
		}
	}

	private func login(_ data: LoginData) {
		container.interactors.accountInteractor
			.login(data, account: $viewModel.account)
	}

	private func signup(_ data: SignupData) {
		container.interactors.accountInteractor
			.signup(data, account: $viewModel.account)
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
