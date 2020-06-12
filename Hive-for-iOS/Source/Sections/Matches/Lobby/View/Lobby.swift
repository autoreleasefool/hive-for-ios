//
//  Lobby.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI
import SwiftUIRefresh

struct Lobby: View {
	@Environment(\.container) private var container

	@ObservedObject private var viewModel: LobbyViewModel

	init(matches: Loadable<[Match]> = .notLoaded) {
		viewModel = LobbyViewModel(matches: matches)
	}

	var body: some View {
		NavigationView {
			content
				.background(Color(.background).edgesIgnoringSafeArea(.all))
				.navigationBarTitle("Lobby")
				.navigationBarItems(leading: settingsButton, trailing: newMatchButton)
				.onReceive(self.viewModel.actionsPublisher) { self.handleAction($0) }
				.sheet(isPresented: $viewModel.settingsOpened) {
					Settings(isOpen: self.$viewModel.settingsOpened)
						.inject(self.container)
				}
				.alert(isPresented: $viewModel.showMatchInProgressWarning) {
					Alert(
						title: Text("Already in match"),
						message: Text("You've already joined a match. " +
							"Please leave the current match before trying to join a new one"),
						dismissButton: .default(Text("OK"))
					)
				}
				.popoverSheet(isPresented: $viewModel.showCreateMatchPrompt) {
					PopoverSheetConfig(
						title: "Create a match?",
						message: "You can create a new match against another player, or play locally vs the computer.",
						buttons: [
							PopoverSheetConfig.ButtonConfig(title: "vs Player", type: .default) {
								self.viewModel.postViewAction(.createOnlineMatchVsPlayer)
							},
							PopoverSheetConfig.ButtonConfig(title: "vs Computer", type: .default) {
								self.viewModel.postViewAction(.createLocalMatchVsComputer)
							},
							PopoverSheetConfig.ButtonConfig(title: "Cancel", type: .cancel) {
								self.viewModel.postViewAction(.cancelCreateMatch)
							},
						]
					)
				}

			noRoomSelectedState
		}
	}

	private var content: AnyView {
		switch viewModel.matches {
		case .notLoaded: return AnyView(notLoadedView)
		case .loading(let cached, _): return AnyView(loadingView(cached))
		case .loaded(let matches): return AnyView(loadedView(matches, loading: false))
		case .failed(let error): return AnyView(failedView(error))
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.onAppear { self.viewModel.postViewAction(.onAppear) }
	}

	private func loadingView(_ matches: [Match]?) -> some View {
		loadedView(matches ?? [], loading: true)
	}

	private func loadedView(_ matches: [Match], loading: Bool) -> some View {
		Group {
			NavigationLink(
				destination: OnlineRoom(id: self.viewModel.currentMatchId, roomType: .online, creatingNewMatch: false),
				isActive: self.viewModel.joiningMatch,
				label: { EmptyView() }
			)

			NavigationLink(
				destination: OnlineRoom(id: nil, roomType: .online, creatingNewMatch: true),
				isActive: self.$viewModel.creatingOnlineRoom,
				label: { EmptyView() }
			)

			NavigationLink(
				destination: OnlineRoom(id: nil, roomType: .local, creatingNewMatch: true),
				isActive: self.$viewModel.creatingLocalRoom,
				label: { EmptyView() }
			)

			if !loading && matches.count == 0 {
				emptyState
			} else {
				List(matches) { match in
					Button(action: {
						self.viewModel.postViewAction(.joinMatch(match.id))
					}, label: {
						LobbyRow(match: match)
					})
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
		Button(action: {
			self.viewModel.postViewAction(.createNewMatch)
		}, label: {
			Image(systemName: "plus")
				.imageScale(.large)
				.accessibility(label: Text("Create Match"))
		})
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

// MARK: - Empty State

extension Lobby {
	private var emptyState: some View {
		EmptyState(
			header: "No matches found",
			message: "There doesn't seem to be anybody waiting to play right now. You can start your own match " +
				"with the '+' button in the top right"
		) {
			self.viewModel.postViewAction(.refresh)
		}
	}

	private func failedState(_ error: Error) -> some View {
		EmptyState(
			header: "An error occurred",
			message: "We can't fetch the lobby right now.\n\(viewModel.errorMessage(from: error))"
		) {
			self.viewModel.postViewAction(.refresh)
		}
	}

	private var noRoomSelectedState: some View {
		EmptyState(
			header: "No room selected",
			message: "Choose a room from the list to join"
		)
	}
}

// MARK: - Actions

extension Lobby {
	var isRefreshing: Binding<Bool> {
		Binding(
			get: {
				if case .loading = self.viewModel.matches {
					return true
				}
				return false
			},
			set: { _ in }
		)
	}

	private func handleAction(_ action: LobbyAction) {
		switch action {
		case .loadOpenMatches:
			loadMatches()
		}
	}

	private func loadMatches() {
		container.interactors.matchInteractor
			.loadOpenMatches(matches: $viewModel.matches)
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
