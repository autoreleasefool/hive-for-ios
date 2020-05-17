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

	@ObservedObject private var viewModel: HistoryViewModel

	@State private var user: Loadable<User>

	init(user: Loadable<User> = .notLoaded) {
		self._user = .init(initialValue: user)
		self.viewModel = HistoryViewModel()
	}

	var body: some View {
		NavigationView {
			content
				.background(Color(.background).edgesIgnoringSafeArea(.all))
				.navigationBarTitle("History")
				.navigationBarItems(leading: settingsButton)
				.onReceive(userUpdates) { self.user = $0 }
				.onReceive(self.viewModel.actionsPublisher) { self.handleAction($0) }
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
			.onAppear { self.viewModel.postViewAction(.onAppear) }
	}

	private func loadedView(_ user: User?) -> some View {
		Group {
			if !(user?.hasAnyMatches ?? false) {
				emptyState
			} else {
				List {
					ForEach(ListSection.allCases, id: \.rawValue) { section in
						Section(header: section.header) {
							if self.viewModel.matches(for: section, fromUser: user).count == 0 {
								section.emptyState
							} else {
								ForEach(self.viewModel.matches(for: section, fromUser: user)) { match in
									NavigationLink(destination: self.details(for: match)) {
										HistoryRow(match: match)
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

	private var settingsButton: some View {
		Button(action: {
			self.viewModel.postViewAction(.openSettings)
		}, label: {
			Image(systemName: "gear")
				.imageScale(.large)
				.accessibility(label: Text("Settings"))
		})
	}

	private func details(for match: Match) -> AnyView {
		if match.isComplete {
			return AnyView(completeMatchDetails(for: match))
		} else {
			return AnyView(lobbyDetails(for: match))
		}
	}

	private func completeMatchDetails(for match: Match) -> some View {
		ScrollView {
			MatchDetail(match: match)
		}
	}

	private func lobbyDetails(for match: Match) -> some View {
		LobbyRoom(creatingRoom: false)
	}
}

// MARK: - Sections

extension History {
	enum ListSection: Int, CaseIterable {
		case inProgress
		case completed

		var header: some View {
			Text(headerText)
				.caption()
				.foregroundColor(Color(.textContrasting))
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
			message: "We can't fetch your history right now.\n\(viewModel.errorMessage(from: error))"
		) {
			self.loadMatchHistory()
		}
	}
}

// MARK: - Actions

extension History {
	private func handleAction(_ action: HistoryAction) {
		switch action {
		case .loadMatchHistory:
			loadMatchHistory()
		case .openSettings:
			openSettings()
		}
	}

	private func loadMatchHistory() {
		container.interactors.userInteractor
			.loadProfile()
	}

	private func openSettings() {
		container.appState[\.routing.mainRouting.settingsIsOpen] = true
	}
}

// MARK: - Updates

extension History {
	private var userUpdates: AnyPublisher<Loadable<User>, Never> {
		container.appState.updates(for: \.userProfile)
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
