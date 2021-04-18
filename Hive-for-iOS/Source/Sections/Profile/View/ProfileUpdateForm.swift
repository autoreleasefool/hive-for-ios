//
//  ProfileUpdateForm.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-12-26.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import HiveFoundation
import SwiftUI

struct ProfileUpdateForm: View {
	@Environment(\.container) private var container
	@Environment(\.presentationMode) private var presentationMode
	@Environment(\.toaster) private var toaster
	@StateObject private var viewModel: ProfileUpdateFormViewModel

	init(
		state: ProfileUpdateFormViewModel.State,
		user: Loadable<User> = .notLoaded
	) {
		_viewModel = StateObject(
			wrappedValue: ProfileUpdateFormViewModel(state: state, user: user)
		)
	}

	var body: some View {
		NavigationView {
			content
				.onReceive(viewModel.actionsPublisher) { handleAction($0) }
				.onReceive(viewModel.$user) { handleUserChange($0) }
				.navigationBarTitle("Update profile", displayMode: .inline)
				.navigationBarItems(leading: cancelButton, trailing: submitButton)
		}
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.user {
		case .notLoaded, .failed: formView
		case .loading, .loaded: loadingView
		}
	}

	// MARK: Content

	private var formView: some View {
		Form {
			if let message = viewModel.state.message {
				Section {
					Text(message)
						.font(.body)
						.foregroundColor(Color(.textRegular))
				}
				.listRowBackground(Color(.backgroundRegular))
			}

			Section(footer: errorFooter) {
				field(for: .displayName)
			}
			.listRowBackground(Color(.backgroundLight))

			if let error = viewModel.errorMessage {
				Section {
					Text(error)
						.font(.body)
						.foregroundColor(Color(.highlightDestructive))
				}
				.listRowBackground(Color(.backgroundRegular))
			}
		}
	}

	private var loadingView: some View {
		LoadingView()
	}

	// MARK: Form

	private func field(for id: ProfileUpdateFormViewModel.FieldItem) -> some View {
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

	private func text(for id: ProfileUpdateFormViewModel.FieldItem) -> Binding<String> {
		switch id {
		case .displayName: return $viewModel.displayName
		}
	}

	@ViewBuilder
	private var errorFooter: some View {
		if let error = viewModel.fieldError {
			Text(error)
				.font(.caption)
				.foregroundColor(Color(.highlightDestructive))
		}
	}

	// MARK: Buttons

	private var submitButton: some View {
		Button {
			viewModel.postViewAction(.submitForm)
		} label: {
			Text("Save")
		}
	}

	@ViewBuilder
	private var cancelButton: some View {
		if viewModel.state.isRequired {
			EmptyView()
		} else {
			Button {
				viewModel.postViewAction(.dismissForm)
			} label: {
				Text("Cancel")
			}
		}
	}
}

// MARK: - Actions

extension ProfileUpdateForm {
	private func handleAction(_ action: ProfileUpdateAction) {
		switch action {
		case .updateProfile(let data):
			updateProfile(data)
		case .dismiss:
			presentationMode.wrappedValue.dismiss()
		}
	}

	private func updateProfile(_ data: User.Update.Request) {
		container.interactors.userInteractor
			.updateProfile(data, user: $viewModel.user)
	}

	private func handleUserChange(_ user: Loadable<User>) {
		switch user {
		case .loaded:
			presentationMode.wrappedValue.dismiss()
			toaster.loaf.send(LoafState("Profile updated", style: .success()))
		case .failed, .loading, .notLoaded:
			break
		}
	}
}
