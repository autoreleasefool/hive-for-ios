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
		NavigationView {
			content
				.onReceive(userUpdates) { self.user = $0 }
				.navigationBarTitle("History")
		}
	}

	private var content: AnyView {
		switch user {
		case .notLoaded: return AnyView(notLoadedView)
		case .loading(let user, _): return AnyView(loadedView(user))
		case .loaded(let user): return AnyView(loadedView(user))
		case .failed(let error): return AnyView(failedView(error))
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.onAppear { self.loadMatchHistory() }
	}

	private func loadedView(_ user: User?) -> some View {
		Group {
			if !(user?.hasAnyMatches ?? false) {
				emptyState
			} else {
				List {
					ForEach(ListSection.allCases, id: \.rawValue) { section in
						Section(header: section.header) {
							if self.matches(for: section, fromUser: user).count == 0 {
								section.emptyState
							} else {
								ForEach(self.matches(for: section, fromUser: user)) { match in
									NavigationLink(destination: self.matchDetails(for: match)) {
										MatchRow(match: match)
									}
								}
							}
						}
					}
				}
			}
		}
	}

	private func failedView(_ error: Error) -> some View {
		failedState(error)
	}
}

// MARK: - Sections

extension History {
	enum ListSection: Int, CaseIterable {
		case inProgress
		case completed

		var header: some View {
			Text(headerText)
				.body()
				.foregroundColor(Color(.textContrasting))
				.padding(.horizontal, length: .m)
				.padding(.vertical, length: .s)
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
		}

		var emptyState: some View {
			Text("No matches found")
				.body()
				.foregroundColor(Color(.textSecondary))
				.padding(.all, length: .m)
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
		}
	}
}

// MARK: - EmptyState

extension History {
	private var emptyState: some View {
		EmptyState(
			header: "No matches found",
			message: "Try playing a match and when you're finished, you'll find it here. You'll also be able to see " +
				"your incomplete matches"
		) {
			self.loadMatchHistory()
		}
	}

	private func failedState(_ error: Error) -> some View {
		EmptyState(
			header: "An error occurred",
			message: "We can't fetch your history right now.\n\(errorMessage(from: error))"
		) {
			self.loadMatchHistory()
		}
	}
}

// MARK: - Actions

extension History {
	private func matches(for section: ListSection, fromUser user: User?) -> [Match] {
		switch section {
		case .inProgress: return user?.activeMatches ?? []
		case .completed: return user?.pastMatches ?? []
		}
	}

	private func matchDetails(for match: Match) -> some View {
		ScrollView {
			MatchDetail(match: match, editable: false)
		}
	}

	private func loadMatchHistory() {
		container.interactors.userInteractor
			.loadProfile()
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
	private func errorMessage(from error: Error) -> String {
		// TODO: get a better error message from the repository error
		error.localizedDescription
	}
}

extension History.ListSection {
	var headerText: String {
		switch self {
		case .inProgress: return "Matches in progress"
		case .completed: return "Past matches"
		}
	}
}

// MARK: - User

private extension User {
	var hasAnyMatches: Bool {
		activeMatches.count + pastMatches.count > 0
	}
}

#if DEBUG
struct HistoryPreview: PreviewProvider {
	static var previews: some View {
		History(user: .loaded(User.users[0]))
			.background(Color(.background).edgesIgnoringSafeArea(.all))
	}
}
#endif
