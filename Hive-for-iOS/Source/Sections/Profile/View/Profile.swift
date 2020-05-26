//
//  Profile.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

struct Profile: View {
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
				.background(Color(.background).edgesIgnoringSafeArea(.all))
				.navigationBarTitle(viewModel.title(forUser: user.value))
				.navigationBarItems(leading: settingsButton)
				.onReceive(viewModel.actionsPublisher) { self.handleAction($0) }
				.onReceive(userUpdates) { self.user = $0 }
				.sheet(isPresented: $viewModel.settingsOpened) {
					Settings(isOpen: self.$viewModel.settingsOpened)
						.inject(self.container)
				}
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}

	private var content: AnyView {
		switch user {
		case .notLoaded: return AnyView(notLoadedView)
		case .loading: return AnyView(loadingView)
		case .loaded(let user): return AnyView(loadedView(user))
		case .failed(let error): return AnyView(failedView(error))
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.onAppear { self.viewModel.postViewAction(.onAppear) }
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

	private func loadedView(_ user: User) -> some View {
		List {
			HexImage(url: user.avatarUrl, placeholder: ImageAsset.borderlessGlyph, stroke: .primary)
				.placeholderTint(.primary)
				.squareImage(.m)
		}
	}

	private func failedView(_ error: Error) -> some View {
		failedState(error)
	}

	private var settingsButton: some View {
		Button(action: {
			self.viewModel.postViewAction(.openSettings)
		}, label: {
			Image(systemName: "gear")
				.imageScale(.large)
				.accessibility(label: Text("Settings"))
		})
	}
}

// MARK: - EmptyState

extension Profile {
	private func failedState(_ error: Error) -> some View {
		EmptyState(
			header: "An error occurred",
			message: "We can't fetch your profile right now.\n\(viewModel.errorMessage(from: error))"
		) {
			self.loadProfile()
		}
	}
}

// MARK: - Actions

extension Profile {
	private func handleAction(_ action: ProfileAction) {
		switch action {
		case .loadProfile:
			loadProfile()
		}
	}

	private func loadProfile() {
		container.interactors.userInteractor
			.loadProfile()
	}
}

// MARK: - Updates

extension Profile {
	private var userUpdates: AnyPublisher<Loadable<User>, Never> {
		container.appState.updates(for: \.userProfile)
	}
}

#if DEBUG
struct ProfilePreview: PreviewProvider {
	static var previews: some View {
		Profile(user: .loaded(User.users[0]))
	}
}
#endif
