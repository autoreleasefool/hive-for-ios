//
//  ProfileView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

struct ProfileView: TabItemView {
	@Environment(\.container) private var container

	@ObservedObject private var viewModel: ProfileViewModel

	// This value can't be moved to the ViewModel because it mirrors the AppState and
	// was causing a re-render loop when in the @ObservedObject view model
	@State private var user: Loadable<User>

	init(user: Loadable<User> = .notLoaded) {
		self._user = .init(initialValue: user)
		self.viewModel = ProfileViewModel()
	}

	var body: some View {
		NavigationView {
			content
				.navigationBarTitle(viewModel.title(forUser: user.value))
				.navigationBarItems(leading: settingsButton)
				.onReceive(viewModel.actionsPublisher) { handleAction($0) }
				.onReceive(userUpdates) { user = $0 }
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}

	@ViewBuilder
	private var content: some View {
		switch user {
		case .notLoaded: notLoadedView
		case .loading: loadingView
		case .loaded(let user): loadedView(user)
		case .failed(let error): failedView(error)
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.onAppear { viewModel.postViewAction(.onAppear) }
	}

	private var loadingView: some View {
		ProgressView()
	}

	private func loadedView(_ user: User) -> some View {
		List {
			HexImage(url: user.avatarUrl, placeholder: ImageAsset.borderlessGlyph, stroke: .highlightPrimary)
				.placeholderTint(.highlightPrimary)
				.squareImage(.m)
		}
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

	func onTabItemAppeared(completion: @escaping (TabItemViewModel) -> Void) -> ProfileView {
		completion(viewModel)
		return self
	}
}

// MARK: - EmptyState

extension ProfileView {
	private func failedState(_ error: Error) -> some View {
		EmptyState(
			header: "An error occurred",
			message: "We can't fetch your profile right now.\n\(viewModel.errorMessage(from: error))",
			action: .init(text: "Refresh") {
				viewModel.postViewAction(.loadProfile)
			}
		)
	}
}

// MARK: - Actions

extension ProfileView {
	private func handleAction(_ action: ProfileAction) {
		switch action {
		case .loadProfile:
			loadProfile()
		case .openSettings:
			container.appState.value.setNavigation(to: .settings)
		}
	}

	private func loadProfile() {
		container.interactors.userInteractor
			.loadProfile()
	}
}

// MARK: - Updates

extension ProfileView {
	private var userUpdates: AnyPublisher<Loadable<User>, Never> {
		container.appState.updates(for: \.userProfile)
	}
}

// MARK: - Preview

#if DEBUG
struct ProfilePreview: PreviewProvider {
	static var previews: some View {
		ProfileView(user: .loaded(User.users[0]))
	}
}
#endif
