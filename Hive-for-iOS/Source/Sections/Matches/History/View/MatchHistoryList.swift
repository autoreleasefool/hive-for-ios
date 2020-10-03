//
//  MatchHistoryList.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-10.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

struct MatchHistoryList: View {
	@Environment(\.container) private var container

	@ObservedObject private var viewModel: MatchHistoryListViewModel

	// This value can't be moved to the ViewModel because it mirrors the AppState and
	// was causing a re-render loop when in the @ObservedObject view model
	@State private var user: Loadable<User>

	init(user: Loadable<User> = .notLoaded) {
		self._user = .init(initialValue: user)
		self.viewModel = MatchHistoryListViewModel()
	}

	var body: some View {
		NavigationView {
			content
				.navigationBarTitle("History")
				.navigationBarItems(leading: settingsButton)
				.onReceive(userUpdates) { user = $0 }
				.onReceive(viewModel.actionsPublisher) { handleAction($0) }
				.sheet(isPresented: $viewModel.settingsOpened) {
					SettingsList(isOpen: $viewModel.settingsOpened)
						.inject(container)
				}

			noRoomSelectedState
		}
	}

	@ViewBuilder
	private var content: some View {
		switch user {
		case .notLoaded: notLoadedView
		case .loading(let user, _): loadedView(user)
		case .loaded(let user): loadedView(user)
		case .failed(let error): failedView(error)
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.onAppear { viewModel.postViewAction(.onAppear) }
	}

	private func loadedView(_ user: User?) -> some View {
		Group {
			if !(user?.hasAnyMatches ?? false) {
				emptyState
			} else {
				List {
					ForEach(ListSection.allCases, id: \.rawValue) { section in
						Section(header: Text(section.headerText)) {
							if viewModel.matches(for: section, fromUser: user).count == 0 {
								section.emptyState
							} else {
								ForEach(viewModel.matches(for: section, fromUser: user)) { match in
									NavigationLink(destination: details(for: match)) {
										HistoryRow(match: match)
											.padding(.vertical)
									}
								}
							}
						}
					}
				}
				.listStyle(InsetGroupedListStyle())
			}
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

	@ViewBuilder
	private func details(for match: Match) -> some View {
		if match.isComplete {
			completeMatchDetails(for: match)
		} else {
			lobbyDetails(for: match)
		}
	}

	private func completeMatchDetails(for match: Match) -> some View {
		ScrollView {
			RoomDetailsView(
				host: match.host?.summary,
				hostIsReady: match.winner?.id == match.host?.id,
				opponent: match.opponent?.summary,
				opponentIsReady: match.winner?.id == match.opponent?.id,
				optionsDisabled: true,
				gameOptionsEnabled: match.gameOptionSet,
				matchOptionsEnabled: match.optionSet,
				gameOptionBinding: { option in
					.constant(match.gameOptionSet.contains(option))
				},
				matchOptionBinding: { option in
					.constant(match.optionSet.contains(option))
				}
			)
		}
	}

	private func lobbyDetails(for match: Match) -> some View {
		EmptyView()
	}
}

// MARK: - Sections

extension MatchHistoryList {
	enum ListSection: Int, CaseIterable {
		case inProgress
		case completed

		var emptyState: some View {
			Text("No matches found")
				.font(.body)
				.padding()
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
		}
	}
}

// MARK: - EmptyState

extension MatchHistoryList {
	private var emptyState: some View {
		EmptyState(
			header: "No matches found",
			message: "Try playing a match and when you're finished, you'll find it here. You'll also be able to see " +
				"your incomplete matches",
			action: .init(text: "Refresh") { loadMatchHistory() }
		)
	}

	private func failedState(_ error: Error) -> some View {
		EmptyState(
			header: "An error occurred",
			message: "We can't fetch your history right now.\n\(viewModel.errorMessage(from: error))",
			action: .init(text: "Refresh") { loadMatchHistory() }
		)
	}

	private var noRoomSelectedState: some View {
		EmptyState(
			header: "No room selected",
			message: "Choose a room from the list to view"
		)
	}
}

// MARK: - Actions

extension MatchHistoryList {
	private func handleAction(_ action: MatchHistoryListAction) {
		switch action {
		case .loadMatchHistory:
			loadMatchHistory()
		}
	}

	private func loadMatchHistory() {
		container.interactors.userInteractor
			.loadProfile()
	}
}

// MARK: - Updates

extension MatchHistoryList {
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

// MARK: - Preview

#if DEBUG
struct HistoryPreview: PreviewProvider {
	static var previews: some View {
		MatchHistoryList(user: .loaded(User.users[0]))
			.background(Color(.backgroundRegular).edgesIgnoringSafeArea(.all))
	}
}
#endif
