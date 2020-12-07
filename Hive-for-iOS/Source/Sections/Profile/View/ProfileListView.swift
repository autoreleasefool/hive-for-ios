//
//  ProfileListView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-10-21.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct ProfileListView: View {
	@Environment(\.container) private var container

	@StateObject private var viewModel: ProfileListViewModel

	init(users: Loadable<[User]> = .notLoaded) {
		_viewModel = StateObject(wrappedValue: ProfileListViewModel(users: users))
	}

	var body: some View {
		NavigationView {
			content
				.background(Color(.backgroundRegular))
				.navigationBarTitle("Users")
				.navigationBarItems(leading: settingsButton)
				.onReceive(viewModel.actionsPublisher) { handleAction($0) }
				.listensToAppStateChanges([.accountChanged]) { _ in
					viewModel.postViewAction(.reload)
				}
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}

	@ViewBuilder
	private var content: some View {
		VStack(spacing: 0) {
			SearchBar("Search users...", icon: "person.fill", text: $viewModel.searchText)
				.padding(.horizontal, Metrics.Spacing.m.rawValue)
				.background(Color(.highlightPrimary).edgesIgnoringSafeArea(.all))

			if viewModel.searchText.isEmpty {
				ProfileView()
				Spacer()
			} else {
				switch viewModel.users {
				case .notLoaded: notLoadedView
				case .loading: loadingView
				case .loaded(let users): loadedView(users)
				case .failed(let error): failedView(error)
				}
			}
		}
	}

	@ViewBuilder
	private var notLoadedView: some View {
		EmptyView()
		Spacer()
	}

	@ViewBuilder
	private var loadingView: some View {
		LoadingView()
		Spacer()
	}

	private func loadedView(_ users: [User]) -> some View {
		List {
			Section(header: SectionHeader("")) {
				ForEach(users) { user in
					NavigationLink(destination: ProfileView(id: user.id, user: .loaded(user))) {
						UserPreview(user.summary)
							.padding(.vertical)
					}
				}
			}
			.listRowBackground(Color(.backgroundLight))
		}
		.listStyle(InsetGroupedListStyle())
	}

	private func failedView(_ error: Error) -> some View {
		failedState(error)
	}

	private var settingsButton: some View {
		Button {
			viewModel.postViewAction(.openSettings)
		} label: {
			Image(systemName: "gear")
				.imageScale(.large)
				.accessibility(label: Text("Settings"))
		}
	}
}

// MARK: - EmptyState

extension ProfileListView {
	private func failedState(_ error: Error) -> some View {
		EmptyState(
			header: "An error occurred",
			message: "We can't fetch any users right now.\n\(viewModel.errorMessage(from: error))",
			action: EmptyState.Action(text: "Refresh") {
				viewModel.postViewAction(.reload)
			}
		)
	}
}

// MARK: - Actions

extension ProfileListView {
	private func handleAction(_ action: ProfileListAction) {
		switch action {
		case .loadUsers(let filter):
			loadUsers(filter: filter)
		case .openSettings:
			container.appState.value.setNavigation(to: .settings)
		}
	}

	private func loadUsers(filter: String) {
		container.interactors.userInteractor
			.loadUsers(filter: filter, users: $viewModel.users)
	}
}
