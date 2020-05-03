//
//  LoginSignupV2.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-02.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

struct LoginSignupV2: View {
	@Environment(\.container) private var container: AppContainer
	@ObservedObject private var viewModel = LoginSignupViewModelV2()

	var body: some View {
		content
			.padding(.all, length: .m)
			.avoidingKeyboard()
			.onReceive(viewModel.loginSubject) {
				self.container.interactors.accountInteractor
					.login($0, account: self.$viewModel.account)
			}
			.onReceive(viewModel.signupSubject) {
				self.container.interactors.accountInteractor
					.signup($0, account: self.$viewModel.account)
			}
			.onReceive(viewModel.$account) {
				if case let .loaded(account) = $0 {
					self.container.interactors.accountInteractor
						.updateAccount(to: account)
				}
			}
	}

	private var content: AnyView {
		switch viewModel.account {
		case .notLoaded, .failed: return AnyView(formView)
		case .loading, .loaded: return AnyView(loadingView)
		}
	}

	private func text(for id: LoginSignupViewModelV2.FieldItem) -> Binding<String> {
		switch id {
		case .email: return $viewModel.email
		case .password: return $viewModel.password
		case .confirmPassword: return $viewModel.confirmPassword
		case .displayName: return $viewModel.displayName
		}
	}

	// MARK: - Content

	private func field(for id: LoginSignupViewModelV2.FieldItem) -> some View {
		LoginField(
			id.title,
			text: text(for: id),
			keyboardType: id.keyboardType,
			returnKeyType: id.returnKeyType(forForm: viewModel.form),
			isActive: viewModel.activeField == id,
			isSecure: id.isSecure,
			onReturn: { self.viewModel.postViewAction(.fieldDidReturn(id)) }
		)
		.frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
		.onTapGesture {
			self.viewModel.postViewAction(.focusField(id))
		}
	}

	private var submitButton: some View {
		Button(action: {
			self.viewModel.postViewAction(.submit)
		}, label: {
			Text(self.viewModel.submitButtonText)
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
				Text(self.viewModel.toggleButtonText)
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

	private var formView: some View {
		ScrollView {
			VStack(spacing: .m) {
				if self.viewModel.shouldShowNotice {
					notice(message: self.viewModel.noticeMessage)
				}

				self.field(for: .email)
				if self.viewModel.form == .signup {
					self.field(for: .displayName)
				}
				self.field(for: .password)
				if self.viewModel.form == .signup {
					self.field(for: .confirmPassword)
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
				ActivityIndicator(isAnimating: true, style: .large)
				Spacer()
			}
			.padding(.top, length: .m)
			.frame(width: geometry.size.width)
		}
	}
}
