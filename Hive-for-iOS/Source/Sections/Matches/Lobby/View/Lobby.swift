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
		case .failed: return AnyView(failedView)
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
		List(matches) { match in
			NavigationLink(destination: MatchDetail(id: match.id)) {
				MatchRow(match: match)
			}
		}
		.pullToRefresh(isShowing: isRefreshing) {
			self.loadMatches()
		}
		.listRowInsets(EdgeInsets(equalTo: .m))
	}

	private var failedView: some View {
		VStack {
			Text("Failed to load matches")
				.subtitle()
				.foregroundColor(Color(.destructive))
			Button(action: {
				self.loadMatches()
			}, label: {
				Text("Tap to try again")
					.body()
					.foregroundColor(Color(.text))
			})
		}
	}

	// MARK: Lobby

	private var newMatchButton: some View {
		NavigationLink(destination: MatchDetail(id: nil)) {
			Image(systemName: "plus")
				.imageScale(.large)
				.accessibility(label: Text("Create Match"))
				.padding(.all, length: .m)
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
		container.interactors.matchInteractor.loadOpenMatches(
			withAccount: container.account,
			matches: $matches
		)
	}
}

struct LobbyPreview: PreviewProvider {
	static var previews: some View {
		let loadable: Loadable<[Match]> = .loaded(Match.matches)
		return Lobby(matches: loadable)
	}
}
