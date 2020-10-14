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

	@StateObject private var viewModel: LobbyListViewModel

	init(spectating: Bool = false, matches: Loadable<[Match]> = .notLoaded) {
		_viewModel = StateObject(
			wrappedValue: LobbyListViewModel(spectating: spectating, matches: matches)
		)
	}

	var body: some View {
		NavigationView {
			content
				.navigationBarTitle(viewModel.spectating ? "Spectate" : "Lobby")
				.navigationBarItems(leading: settingsButton, trailing: newMatchButton)
				.onReceive(viewModel.actionsPublisher) { handleAction($0) }
				.listensToAppStateChanges([.accountChanged]) { reason in
					switch reason {
					case .accountChanged:
						viewModel.postViewAction(
							.networkStatusChanged(isOffline: container.appState.value.account.value?.isOffline ?? true)
						)
					case .toggledFeature:
						break
					}
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

	@ViewBuilder
	private func loadedView(_ matches: [Match], loading: Bool) -> some View {
		NavigationLink(
			destination: OnlineRoomView(id: viewModel.currentMatchId, creatingNewMatch: false),
			isActive: viewModel.joiningMatch
		) { EmptyView() }

		NavigationLink(
			destination: OnlineRoomView(id: nil, creatingNewMatch: true),
			isActive: $viewModel.creatingOnlineRoom
		) { EmptyView() }

		NavigationLink(
			destination: AgentPicker(isActive: $viewModel.creatingLocalRoom),
			isActive: $viewModel.creatingLocalRoom
		) { EmptyView() }

		NavigationLink(
			destination: SpectatorRoomView(id: viewModel.currentSpectatingMatchId),
			isActive: viewModel.spectatingMatch
		) { EmptyView() }

		if !loading && matches.count == 0 {
			emptyState
		} else {
			List {
				Section(header: Text("Open")) {
					ForEach(matches) { match in
						Button {
							viewModel.postViewAction(.joinMatch(match.id))
						} label: {
							LobbyRow(match: match)
						}
						.padding(.vertical)
					}
				}
			}
			.listStyle(InsetGroupedListStyle())
			.onAppear {
				viewModel.postViewAction(.onListAppear)
			}
			.onDisappear {
				viewModel.postViewAction(.onListDisappear)
			}
		}
	}

	private func failedView(_ error: Error) -> some View {
		failedState(error)
	}

	// MARK: Lobby

	@ViewBuilder
	private var newMatchButton: some View {
		if viewModel.spectating {
			EmptyView()
		} else {
			Button {
				viewModel.postViewAction(.createNewMatch)
			} label: {
				Image(systemName: "plus")
					.imageScale(.large)
					.accessibility(label: Text("Create Match"))
			}
		}
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
		case .openSettings:
			container.appState.value.setNavigation(to: .settings)
		case .openLoginForm:
			container.appState.value.setNavigation(to: .login)
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
			.preferredColorScheme(.light)
	}
}
#endif
