//
//  Lobby.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import SwiftUIRefresh

struct Lobby: View {
	@Environment(\.container) private var container: AppContainer

	@State private var matches: Loadable<[Match]>

	init(matches: Loadable<[Match]> = .notLoaded) {
		self._matches = .init(initialValue: matches)
	}

	var body: some View {
		NavigationView {
			content
				.navigationBarTitle("Lobby")
				.navigationBarItems(trailing: newMatchButton)
		}
	}

	private var content: AnyView {
		switch matches {
		case .notLoaded: return AnyView(notLoadedView)
		case .loading(let cached, _): return AnyView(loadingView(cached))
		case .loaded(let matches): return AnyView(loadedView(matches))
		case .failed(let error): return AnyView(failedView(error))
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.onAppear { self.loadMatches() }
	}

	private func loadingView(_ matches: [Match]?) -> some View {
		loadedView(matches ?? [])
	}

	private func loadedView(_ matches: [Match]) -> some View {
		Group {
			if matches.count == 0 {
				emptyState
			} else {
				List(matches) { match in
					NavigationLink(destination: LobbyRoom(id: match.id)) {
						LobbyRow(match: match)
					}
				}
				.pullToRefresh(isShowing: isRefreshing) {
					self.loadMatches()
				}
				.listRowInsets(EdgeInsets(equalTo: .m))
			}
		}
	}

	private func failedView(_ error: Error) -> some View {
		failedState(error)
	}

	// MARK: Lobby

	private var newMatchButton: some View {
		NavigationLink(destination: LobbyRoom(id: nil)) {
			Image(systemName: "plus")
				.imageScale(.large)
				.accessibility(label: Text("Create Match"))
				.padding(.all, length: .m)
		}
	}
}

// MARK: - Empty State

extension Lobby {
	private var emptyState: some View {
		EmptyState(
			header: "No matches found",
			message: "There doesn't seem to be anybody waiting to play right now. You can start your own match " +
				"with the '+' button in the top right"
		) {
			self.loadMatches()
		}
	}

	private func failedState(_ error: Error) -> some View {
		EmptyState(
			header: "An error occurred",
			message: "We can't fetch the lobby right now.\n\(errorMessage(from: error))"
		) {
			self.loadMatches()
		}
	}
}

// MARK: - Actions

extension Lobby {
	var isRefreshing: Binding<Bool> {
		Binding(
			get: {
				if case .loading = self.matches {
					return true
				}
				return false
			},
			set: { _ in }
		)
	}

	private func loadMatches() {
		container.interactors.matchInteractor
			.loadOpenMatches(matches: $matches)
	}
}

// MARK: - Strings

extension Lobby {
	private func errorMessage(from error: Error) -> String {
		guard let matchError = error as? MatchRepositoryError else {
			return error.localizedDescription
		}

		switch matchError {
		case .apiError(let apiError): return apiError.errorDescription ?? apiError.localizedDescription
		}
	}
}

#if DEBUG
struct LobbyPreview: PreviewProvider {
	static var previews: some View {
		let loadable: Loadable<[Match]> = .loaded(Match.matches)
		return Lobby(matches: loadable)
	}
}
#endif
