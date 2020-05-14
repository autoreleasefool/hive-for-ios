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
	@Environment(\.container) private var container: AppContainer

	@ObservedObject private var viewModel: ProfileViewModel

	init(user: Loadable<User> = .notLoaded) {
		self.viewModel = ProfileViewModel(user: user)
	}

	var body: some View {
		NavigationView {
			content
				.background(Color(.background).edgesIgnoringSafeArea(.all))
				.navigationBarTitle(viewModel.title)
				.navigationBarItems(leading: settingsButton)
				.onReceive(viewModel.actionsPublisher) { self.handleAction($0) }
				.onReceive(userUpdates) { self.viewModel.user = $0 }
		}
	}

	private var content: AnyView {
		switch viewModel.user {
		case .notLoaded: return AnyView(notLoadedView)
		case .loading: return AnyView(loadingView)
		case .loaded(let user): return AnyView(loadedView(user))
		case .failed(let error): return AnyView(failedView(error))
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.onAppear { self.viewModel.postViewAction(.loadProfile) }
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
		case .openSettings:
			openSettings()
		}
	}

	private func loadProfile() {
		container.interactors.userInteractor
			.loadProfile()
	}

	private func openSettings() {
		container.appState[\.routing.mainRouting.settingsIsOpen] = true
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
		Profile()
	}
}
#endif
