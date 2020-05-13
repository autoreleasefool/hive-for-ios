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

	@State private var user: Loadable<User> = .notLoaded

	init(user: Loadable<User> = .notLoaded) {
		self._user = .init(initialValue: user)
	}

	var body: some View {
		NavigationView {
			content
				.navigationBarTitle(title)
				.navigationBarItems(leading: settingsButton)
		}
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
			.onAppear { self.loadProfile() }
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
			self.container.appState[\.routing.mainRouting.settingsIsOpen] = true
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
			message: "We can't fetch your profile right now.\n\(errorMessage(from: error))"
		) {
			self.loadProfile()
		}
	}
}

// MARK: - Actions

extension Profile {
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

// MARK: - Strings

extension Profile {
	private var title: String {
		user.value?.displayName ?? "Profile"
	}

	private func errorMessage(from error: Error) -> String {
		guard let userError = error as? UserRepositoryError else {
			return error.localizedDescription
		}

		switch userError {
		case .missingID: return "Account missing"
		case .apiError(let apiError): return apiError.errorDescription ?? apiError.localizedDescription
		}
	}
}

#if DEBUG
struct ProfilePreview: PreviewProvider {
	static var previews: some View {
		Profile()
	}
}
#endif
