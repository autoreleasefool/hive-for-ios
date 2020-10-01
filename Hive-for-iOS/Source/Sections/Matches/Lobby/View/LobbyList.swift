//
//  LobbyList.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

struct LobbyList: View {
	@Environment(\.container) private var container

	@ObservedObject private var viewModel: LobbyListViewModel

	init(spectating: Bool, matches: Loadable<[Match]> = .notLoaded) {
		viewModel = LobbyListViewModel(spectating: spectating, matches: matches)
	}

	var body: some View {
		NavigationView {
			content
				.navigationBarTitle(viewModel.spectating ? "Spectate" : "Lobby")
				.navigationBarItems(leading: settingsButton, trailing: newMatchButton)
				.onReceive(viewModel.actionsPublisher) { handleAction($0) }
				.sheet(isPresented: $viewModel.settingsOpened) {
					SettingsList(isOpen: $viewModel.settingsOpened)
						.inject(container)
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
								viewModel.postViewAction(.createOnlineMatchVsPlayer)
							},
							PopoverSheetConfig.ButtonConfig(title: "vs Computer", type: .default) {
								viewModel.postViewAction(.createLocalMatchVsComputer)
							},
							PopoverSheetConfig.ButtonConfig(title: "Cancel", type: .cancel) {
								viewModel.postViewAction(.cancelCreateMatch)
							},
						]
					)
				}

			noRoomSelectedState
		}
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.matches {
		case .notLoaded: notLoadedView
		case .loading(let cached, _): loadingView(cached)
		case .loaded(let matches): loadedView(matches, loading: false)
		case .failed(let error): failedView(error)
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.onAppear {
				viewModel.postViewAction(
					.onAppear(isOffline: container.account?.isOffline ?? false )
				)
			}
	}

	private func loadingView(_ matches: [Match]?) -> some View {
		loadedView(matches ?? [], loading: true)
	}

	private func loadedView(_ matches: [Match], loading: Bool) -> some View {
		Group {
			NavigationLink(
				destination: OnlineRoomView(id: viewModel.currentMatchId, creatingNewMatch: false),
				isActive: viewModel.joiningMatch,
				label: { EmptyView() }
			)

			NavigationLink(
				destination: OnlineRoomView(id: nil, creatingNewMatch: true),
				isActive: $viewModel.creatingOnlineRoom,
				label: { EmptyView() }
			)

			NavigationLink(
				destination: AgentPicker(isActive: $viewModel.creatingLocalRoom),
				isActive: $viewModel.creatingLocalRoom,
				label: { EmptyView() }
			)

			NavigationLink(
				destination: SpectatorRoomView(id: viewModel.currentSpectatingMatchId),
				isActive: viewModel.spectatingMatch,
				label: { EmptyView() }
			)

			if !loading && matches.count == 0 {
				emptyState
			} else {
				List {
					ForEach(matches) { match in
						Button(action: {
							viewModel.postViewAction(.joinMatch(match.id))
						}, label: {
							LobbyRow(match: match)
						})
					}
				}
				.listStyle(PlainListStyle())
				.onAppear {
					viewModel.postViewAction(.onListAppear)
				}
				.onDisappear {
					viewModel.postViewAction(.onListDisappear)
				}
			}
		}
	}

	private func failedView(_ error: Error) -> some View {
		failedState(error)
	}

	// MARK: Lobby

	private var newMatchButton: some View {
		guard !viewModel.spectating else { return AnyView(EmptyView()) }
		return AnyView(Button(action: {
			viewModel.postViewAction(.createNewMatch)
		}, label: {
			Image(systemName: "plus")
				.imageScale(.large)
				.accessibility(label: Text("Create Match"))
		}))
	}

	private var settingsButton: AnyView {
		guard !viewModel.spectating else { return AnyView(EmptyView()) }
		return AnyView(Button(action: {
			viewModel.postViewAction(.openSettings)
		}, label: {
			Image(systemName: "gear")
				.imageScale(.large)
				.accessibility(label: Text("Settings"))
		}))
	}
}

// MARK: - Empty State

extension LobbyList {

	@ViewBuilder
	private var emptyState: some View {
		if viewModel.isOffline {
			offlineState
		} else {
			EmptyState(
				header: "No matches found",
				message: viewModel.spectating
					? "There don't seem to be any active games right now. Go to the lobby to start your own"
					: "There doesn't seem to be anybody waiting to play right now. You can start your own match " +
						"with the '+' button in the top right",
				action: .init(text: "Refresh") { viewModel.postViewAction(.refresh) }
			)
		}
	}

	@ViewBuilder
	private func failedState(_ error: Error) -> some View {
		if let error = error as? MatchRepositoryError, case .usingOfflineAccount = error {
			offlineState
		} else {
			EmptyState(
				header: "An error occurred",
				message: "We can't fetch the lobby right now.\n\(viewModel.errorMessage(from: error))",
				action: .init(text: "Refresh") { viewModel.postViewAction(.refresh) }
			)
		}
	}

	private var offlineState: some View {
		EmptyState(
			header: "You're offline",
			message: viewModel.spectating
				? "You can't spectate offline. Log in to spectate"
				: "You can play a game against the computer by tapping below",
			action: viewModel.spectating
				? .init(text: "Log in") { viewModel.postViewAction(.logIn) }
				: .init(text: "Play local match") { viewModel.postViewAction(.createLocalMatchVsComputer) }
		)
	}

	private var noRoomSelectedState: some View {
		EmptyState(
			header: "No room selected",
			message: "Choose a room from the list to join"
		)
	}
}

// MARK: - Actions

extension LobbyList {
	private func handleAction(_ action: LobbyListAction) {
		switch action {
		case .loadMatches:
			loadMatches()
		}
	}

	private func loadMatches() {
		if viewModel.spectating {
			container.interactors.matchInteractor
				.loadActiveMatches(matches: $viewModel.matches)
		} else {
			container.interactors.matchInteractor
				.loadOpenMatches(matches: $viewModel.matches)
		}
	}
}

// MARK: - Preview

#if DEBUG
struct LobbyPreview: PreviewProvider {
	static var previews: some View {
		return LobbyList(spectating: false, matches: .loaded(Match.matches))
	}
}
#endif
