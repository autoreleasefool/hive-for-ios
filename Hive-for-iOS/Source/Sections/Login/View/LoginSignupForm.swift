//
//  LoginSignupForm.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-02.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import AuthenticationServices
import Combine
import SwiftUI

struct LoginSignupForm: View {
	@Environment(\.container) private var container
	@Environment(\.toaster) private var toaster
	@Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
	@Environment(\.presentationMode) private var presentationMode
	@StateObject private var viewModel: LoginSignupFormViewModel

	init(
		defaultForm: LoginSignupFormViewModel.Form = .login,
		account: Loadable<AnyAccount> = .notLoaded
	) {
		_viewModel = StateObject(
			wrappedValue: LoginSignupFormViewModel(defaultForm: defaultForm, account: account)
		)
	}

	var body: some View {
		NavigationView {
			content
				.onReceive(viewModel.actionsPublisher) { handleAction($0) }
				.onReceive(viewModel.$account) { handleAccountChange($0) }
				.navigationBarTitle("Play online", displayMode: .inline)
				.navigationBarItems(leading: cancelButton, trailing: submitButton)
		}
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.account {
		case .notLoaded, .failed: formView
		case .loading, .loaded: loadingView
		}
	}

	// MARK: Content

	@ViewBuilder
	private var formView: some View {
		Form {
			Section(footer: noticeFooter) {
				if viewModel.shouldShow(field: .email) {
					field(for: .email)
				}
				if viewModel.shouldShow(field: .displayName) {
					field(for: .displayName)
				}
				if viewModel.shouldShow(field: .password) {
					secureField(for: .password)
				}
				if viewModel.shouldShow(field: .confirmPassword) {
					secureField(for: .confirmPassword)
				}
			}
			.listRowBackground(Color(.backgroundLight))

			if viewModel.form == .signInWithApple {
				SignInWithAppleButton(.signIn) { _ in } onCompletion: { result in
					viewModel.postViewAction(.signInWithApple(result))
				}
				.signInWithAppleButtonStyle(.white)
			}

			if let header = viewModel.toggleSectionHeaderText,
				let toggleButton = viewModel.toggleButtonText {
				Section(header: SectionHeader(header)) {
					Button {
						viewModel.postViewAction(.toggleForm)
					} label: {
						Text(toggleButton)
							.font(.body)
							.foregroundColor(Color(.highlightRegular))
					}

					if container.has(feature: .guestMode) && viewModel.form == .login {
						Button {
							viewModel.postViewAction(.playAsGuest)
						} label: {
							Text("Play as guest")
								.font(.body)
								.foregroundColor(Color(.highlightRegular))
						}
					}
				}
				.listRowBackground(Color(.backgroundLight))
			}
		}
	}

	private var loadingView: some View {
		LoadingView()
	}

	// MARK: Form

	private func secureField(for id: LoginSignupFormViewModel.FieldItem) -> some View {
		ZStack(alignment: .leading) {
			if text(for: id).wrappedValue.isEmpty {
				Text(id.title).foregroundColor(Color(.textSecondary))
			}
			SecureField("", text: text(for: id))
				.foregroundColor(Color(.textRegular))
				.textContentType(id.textContentType)
				.keyboardType(id.keyboardType)
		}
	}

	private func field(for id: LoginSignupFormViewModel.FieldItem) -> some View {
		ZStack(alignment: .leading) {
			if text(for: id).wrappedValue.isEmpty {
				Text(id.title).foregroundColor(Color(.textSecondary))
			}
			TextField("", text: text(for: id))
				.foregroundColor(Color(.textRegular))
				.textContentType(id.textContentType)
				.keyboardType(id.keyboardType)
		}
	}

	private func text(for id: LoginSignupFormViewModel.FieldItem) -> Binding<String> {
		switch id {
		case .email: return $viewModel.email
		case .password: return $viewModel.password
		case .confirmPassword: return $viewModel.confirmPassword
		case .displayName: return $viewModel.displayName
		}
	}

	@ViewBuilder
	private var noticeFooter: some View {
		if viewModel.shouldShowNotice {
			notice(message: "There was an error connecting to the server. Are you connected to the Internet?")
		}
	}

	@ViewBuilder
	private var submitButton: some View {
		if viewModel.form != .signInWithApple {
			Button {
				viewModel.postViewAction(.submitForm)
			} label: {
				Text(viewModel.submitButtonText)
			}
		}
	}

	private var cancelButton: some View {
		Button {
			viewModel.postViewAction(.dismissForm)
		} label: {
			Text("Cancel")

		}
	}

	private func notice(message: String) -> some View {
		Text(message)
			.font(.body)
			.foregroundColor(Color(.highlightPrimary))
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
		case .signInWithApple(let data):
			signInWithApple(data)
		case .createGuestAccount:
			createGuestAccount()
		case .showLoaf(let loaf):
			toaster.loaf.send(loaf)
		case .dismiss:
			presentationMode.wrappedValue.dismiss()
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

	private func signInWithApple(_ data: User.SignInWithApple.Request) {
		container.interactors.accountInteractor
			.signInWithApple(data, account: $viewModel.account)
	}

	private func createGuestAccount() {
		container.interactors.accountInteractor
			.createGuestAccount(account: $viewModel.account)
	}

	private func handleAccountChange(_ account: Loadable<AnyAccount>) {
		switch account {
		case .loaded:
			viewModel.postViewAction(.dismissForm)
		case .failed, .loading, .notLoaded:
			break
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
	}
}
#endif
