//
//  LobbyV2.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import SwiftUIRefresh

struct LobbyV2: View {
	@Environment(\.container) private var container: AppContainer
	@ObservedObject private var viewModel = LobbyViewModelV2()

	var body: some View {
		NavigationView {
			content
				.navigationBarTitle("Lobby")
				.navigationBarItems(trailing: newMatchButton)
		}
	}

	private var content: AnyView {
		switch viewModel.matches {
		case .notLoaded: return AnyView(notLoadedView)
		case .loading(let cached, _): return AnyView(loadingView(cached))
		case .loaded(let matches): return AnyView(loadedView(matches))
		case .failed: return AnyView(failedView)
		}
	}

	// MARK: - Content

	private var newMatchButton: some View {
		NavigationLink(destination: MatchDetailV2(id: nil)) {
			Image(systemName: "plus")
				.imageScale(.large)
				.accessibility(label: Text("Create Match"))
				.padding(.all, length: .m)
		}
	}

	private var notLoadedView: some View {
		Text("")
			.onAppear { self.loadMatches() }
	}

	private func loadingView(_ matches: [Match]?) -> some View {
		loadedView(matches ?? [])
	}

	private func loadedView(_ matches: [Match]) -> some View {
		List(matches) { match in
			NavigationLink(destination: MatchDetailV2(id: match.id)) {
				MatchRow(match: match)
			}
		}
		.pullToRefresh(isShowing: viewModel.isRefreshing) {
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

	// MARK: - Actions

	private func loadMatches() {
		container.interactors.matchInteractor.loadOpenMatches(
			withAccount: container.account,
			matches: $viewModel.matches
		)
	}
}
