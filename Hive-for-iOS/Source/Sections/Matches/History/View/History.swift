//
//  History.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-10.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI
import SwiftUIRefresh

struct History: View {
	@Environment(\.container) private var container: AppContainer

	@State private var user: Loadable<User>

	init(user: Loadable<User> = .notLoaded) {
		self._user = .init(initialValue: user)
	}

	var body: some View {
		content
			.onReceive(userUpdates) { self.user = $0 }
	}

	private var content: AnyView {
		switch user {
		case .notLoaded: return AnyView(notLoadedView)
		case .loading(let user, _): return AnyView(loadingView(user?.activeMatches, user?.pastMatches))
		case .loaded(let user): return AnyView(loadedView(user.activeMatches, user.pastMatches))
		case .failed: return AnyView(failedView)
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.onAppear { self.loadMatchHistory() }
	}

	private func loadingView(_ matchesInProgress: [Match]?, _ completedMatches: [Match]?) -> some View {
		loadedView(matchesInProgress ?? [], completedMatches ?? [])
	}

	private func loadedView(_ matchesInProgress: [Match], _ completedMatches: [Match]) -> some View {
		return List {
			Section(header: self.inProgressHeader) {
				ForEach(matchesInProgress) { match in
					NavigationLink(destination: MatchDetail(id: match.id)) {
						MatchRow(match: match)
					}
				}
			}

			Section(header: self.completedHeader) {
				ForEach(completedMatches) { match in
					NavigationLink(destination: MatchDetail(id: match.id)) {
						MatchRow(match: match)
					}
				}
			}
		}
	}

	// TODO: failed view
	private var failedView: some View {
		EmptyView()
	}

	// MARK: History

	private var inProgressHeader: some View {
		Text("Matches in progress")
	}

	private var completedHeader: some View {
		Text("Past matches")
	}
}

// MARK: - Actions

extension History {
	private func loadMatchHistory() {
//		container.interactors.matchInteractor.
	}
}

// MARK: - Updates

extension History {
	private var userUpdates: AnyPublisher<Loadable<User>, Never> {
		container.appState.updates(for: \.userProfile)
	}
}

// MARK: - Strings

extension History {
	private var inProgressHeaderText: String {
		""
	}
}
