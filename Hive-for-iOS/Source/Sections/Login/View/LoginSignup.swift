//
//  LoginSignup.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-02.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI
import Introspect

struct LoginSignup: View {
	@Environment(\.container) private var container
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
				secureField(for: .password)
				if viewModel.form == .signup {
					secureField(for: .confirmPassword)
				}

				submitButton
				toggleButton
				Spacer()
				playOfflineButton
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

	private func secureField(for id: LoginSignupViewModel.FieldItem) -> some View {
		SecureField(
			id.title,
			text: text(for: id),
			onCommit: {
				self.viewModel.postViewAction(.didReturn(from: id))
			}
		)
		.introspectTextField {
			if self.viewModel.activeField == id {
				$0.becomeFirstResponder()
			}
		}
		.onTapGesture { self.viewModel.postViewAction(.focusField(id)) }
		.modifier(LoginFieldAppearance(id: id, isActive: viewModel.activeField == id))
	}

	private func field(for id: LoginSignupViewModel.FieldItem) -> some View {
		TextField(
			id.title,
			text: text(for: id),
			onCommit: {
				self.viewModel.postViewAction(.didReturn(from: id))
			}
		)
		.introspectTextField {
			if self.viewModel.activeField == id {
				$0.becomeFirstResponder()
			}
		}
		.onTapGesture { self.viewModel.postViewAction(.focusField(id)) }
		.modifier(LoginFieldAppearance(id: id, isActive: viewModel.activeField == id))
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
		BasicButton<Never>(viewModel.submitButtonText, action: {
			self.viewModel.postViewAction(.submitForm)
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

	private var playOfflineButton: some View {
		BasicButton<Never>(viewModel.playOfflineButtonText, action: {
			self.viewModel.postViewAction(.playOffline)
		})
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
		case .playOffline:
			playOffline()
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

	private func playOffline() {
		container.interactors.accountInteractor
			.playOffline(account: $viewModel.account)
	}
}

// MARK: Login Field Modifier

private extension LoginSignup {
	struct LoginFieldAppearance: ViewModifier {
		let id: LoginSignupViewModel.FieldItem
		let isActive: Bool

		func body(content: Content) -> some View {
			content
				.textContentType(id.textContentType)
				.keyboardType(id.keyboardType)
				.foregroundColor(Color(isActive ? .primary : .text))
				.padding(.all, length: .m)
				.frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
				.overlay(
					RoundedRectangle(cornerRadius: .s)
						.stroke(Color(isActive ? .primary : .text), lineWidth: 1)
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
		.background(Color(.background).edgesIgnoringSafeArea(.all))
	}
}
#endif
