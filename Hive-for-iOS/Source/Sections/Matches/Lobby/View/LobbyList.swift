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
				.background(Color(.backgroundRegular).edgesIgnoringSafeArea(.all))
				.navigationBarTitle(viewModel.spectating ? "Spectate" : "Lobby")
				.navigationBarItems(leading: settingsButton, trailing: newMatchButton)
				.onReceive(self.viewModel.actionsPublisher) { self.handleAction($0) }
				.sheet(isPresented: $viewModel.settingsOpened) {
					SettingsList(isOpen: self.$viewModel.settingsOpened)
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
			.onAppear {
				self.viewModel.postViewAction(
					.onAppear(isOffline: self.container.account?.isOffline ?? false )
				)
			}
	}

	private func loadingView(_ matches: [Match]?) -> some View {
		loadedView(matches ?? [], loading: true)
	}

	private func loadedView(_ matches: [Match], loading: Bool) -> some View {
		Group {
			NavigationLink(
				destination: OnlineRoomView(id: self.viewModel.currentMatchId, creatingNewMatch: false),
				isActive: self.viewModel.joiningMatch,
				label: { EmptyView() }
			)

			NavigationLink(
				destination: OnlineRoomView(id: nil, creatingNewMatch: true),
				isActive: self.$viewModel.creatingOnlineRoom,
				label: { EmptyView() }
			)

			NavigationLink(
				destination: AgentPicker(isActive: self.$viewModel.creatingLocalRoom),
				isActive: self.$viewModel.creatingLocalRoom,
				label: { EmptyView() }
			)

			NavigationLink(
				destination: SpectatorRoomView(id: self.viewModel.currentSpectatingMatchId),
				isActive: self.viewModel.spectatingMatch,
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
				.listRowInsets(EdgeInsets(equalTo: .m))
				.onAppear {
					self.viewModel.postViewAction(.onListAppear)
				}
				.onDisappear {
					self.viewModel.postViewAction(.onListDisappear)
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
			self.viewModel.postViewAction(.createNewMatch)
		}, label: {
			Image(systemName: "plus")
				.imageScale(.large)
				.accessibility(label: Text("Create Match"))
		}))
	}

	private var settingsButton: AnyView {
		guard !viewModel.spectating else { return AnyView(EmptyView()) }
		return AnyView(Button(action: {
			self.viewModel.postViewAction(.openSettings)
		}, label: {
			Image(systemName: "gear")
				.imageScale(.large)
				.accessibility(label: Text("Settings"))
		}))
	}
}

// MARK: - Empty State

extension LobbyList {
	private var emptyState: AnyView {
		if viewModel.isOffline {
			return AnyView(offlineState)
		} else {
			return AnyView(EmptyState(
				header: "No matches found",
				message: viewModel.spectating
					? "There don't seem to be any active games right now. Go to the lobby to start your own"
					: "There doesn't seem to be anybody waiting to play right now. You can start your own match " +
						"with the '+' button in the top right",
				action: .init(text: "Refresh") { self.viewModel.postViewAction(.refresh) }
			))
		}
	}

	private func failedState(_ error: Error) -> AnyView {
		if let error = error as? MatchRepositoryError, case .usingOfflineAccount = error {
			return AnyView(offlineState)
		} else {
			return AnyView(EmptyState(
				header: "An error occurred",
				message: "We can't fetch the lobby right now.\n\(viewModel.errorMessage(from: error))",
				action: .init(text: "Refresh") { self.viewModel.postViewAction(.refresh) }
			))
		}
	}

	private var offlineState: some View {
		EmptyState(
			header: "You're offline",
			message: viewModel.spectating
				? "You can't spectate offline. Log in to spectate"
				: "You can play a game against the computer by tapping below",
			action: viewModel.spectating
				? .init(text: "Log in") { self.viewModel.postViewAction(.logIn) }
				: .init(text: "Play local match") { self.viewModel.postViewAction(.createLocalMatchVsComputer) }
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

#if DEBUG
struct LobbyPreview: PreviewProvider {
	static var previews: some View {
		let loadable: Loadable<[Match]> = .loaded(Match.matches)
		return LobbyList(spectating: false, matches: loadable)
	}
}
#endif
