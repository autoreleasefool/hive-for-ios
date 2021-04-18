//
//  LobbyList.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import HiveFoundation
import SwiftUI

struct LobbyList: View {
	@Environment(\.container) private var container

	@StateObject private var viewModel: LobbyListViewModel

	init(spectating: Bool = false, matches: Loadable<[Match]> = .notLoaded) {
		_viewModel = StateObject(
			wrappedValue: LobbyListViewModel(isSpectating: spectating, matches: matches)
		)
	}

	var body: some View {
		NavigationView {
			content
				.navigationBarTitle(viewModel.isSpectating ? "Spectate" : "Lobby")
				.navigationBarItems(leading: settingsButton, trailing: trailingButtons)
				.onReceive(viewModel.actionsPublisher) { handleAction($0) }
				.listensToAppStateChanges(
					[
						.accountChanged,
						.toggledFeature(.aiOpponents),
						.toggledFeature(.accounts),
						.toggledFeature(.signInWithApple),
						.toggledFeature(.guestMode),
					]
				) { reason in
					switch reason {
					case .accountChanged:
						viewModel.postViewAction(
							.networkStatusChanged(isOffline: container.appState.value.account.value?.isOffline ?? true)
						)
					case .toggledFeature(.aiOpponents):
						viewModel.postViewAction(.aiModeToggled(container.has(feature: .aiOpponents)))
					case .toggledFeature(.accounts), .toggledFeature(.signInWithApple), .toggledFeature(.guestMode):
						viewModel.postViewAction(.featuresChanged)
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
				.alert(isPresented: $viewModel.showCreateMatchPrompt) {
					Alert(
						title: Text("Create a match?"),
						message: Text("You can create a new match online, or play locally vs the computer or a friend."),
						primaryButton: .default(Text("Online")) {
							viewModel.postViewAction(.createOnlineMatch)
						},
						secondaryButton: .default(Text("Local")) {
							viewModel.postViewAction(.createLocalMatch)
						}
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
			.background(Color(.backgroundRegular).edgesIgnoringSafeArea(.all))
			.onAppear {
				viewModel.postViewAction(
					.onAppear(
						isOffline: container.account?.isOffline ?? false,
						aiEnabled: container.has(feature: .aiOpponents)
					)
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
			destination: LocalOpponentPicker(isActive: $viewModel.creatingLocalRoom),
			isActive: $viewModel.creatingLocalRoom
		) { EmptyView() }

		NavigationLink(
			destination: SpectatorRoomView(id: viewModel.currentSpectatingMatchId),
			isActive: viewModel.spectatingMatch
		) { EmptyView() }

		if matches.count == 0 {
			if loading {
				LoadingView()
			} else {
				emptyState
			}
		} else {
			List {
				Section(header: SectionHeader("Open")) {
					ForEach(matches) { match in
						Button {
							viewModel.postViewAction(.joinMatch(match.id))
						} label: {
							LobbyRow(match: match)
						}
						.padding(.vertical)
					}
				}
				.listRowBackground(Color(.backgroundLight))
			}
			.listStyle(InsetGroupedListStyle())
		}
	}

	private func failedView(_ error: Error) -> some View {
		failedState(error)
	}

	// MARK: Lobby

	private var trailingButtons: some View {
		HStack(spacing: Metrics.Spacing.l.rawValue) {
			refreshButton
			newMatchButton
		}
	}

	@ViewBuilder
	private var newMatchButton: some View {
		if viewModel.isSpectating {
			EmptyView()
		} else {
			Button {
				viewModel.postViewAction(.createNewMatch)
			} label: {
				Image(systemName: "plus")
					.imageScale(.large)
					.accessibility(label: Text("Create Match"))
					.accessibility(identifier: "createMatch")
			}
		}
	}

	private var refreshButton: some View {
		Button {
			viewModel.postViewAction(.refresh)
		} label: {
			Image(systemName: "arrow.clockwise")
				.imageScale(.large)
				.accessibility(label: Text("Refresh"))
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
				message: viewModel.isSpectating
					? "There don't seem to be any active games right now. Go to the lobby to start your own"
					: "There doesn't seem to be anybody waiting to play right now. You can start your own match " +
						"with the '+' button in the top right",
				action: EmptyState.Action(text: "Refresh") { viewModel.postViewAction(.refresh) }
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
				action: EmptyState.Action(text: "Refresh") { viewModel.postViewAction(.refresh) }
			)
		}
	}

	private var offlineState: some View {
		let offlineStateAction = viewModel.offlineStateAction(
			isAccountsEnabled: container.has(feature: .accounts),
			isGuestModeEnabled: container.has(feature: .guestMode)
		)

		return EmptyState(
			header: "You're offline",
			message: viewModel.offlineStateMessage(
				isAccountsEnabled: container.has(feature: .accounts),
				isGuestModeEnabled: container.has(feature: .guestMode)
			),
			action: offlineStateAction != nil
				? EmptyState.Action(text: offlineStateAction!) { viewModel.postViewAction(.offlineStateAction) }
				: nil
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
			container.appState[\.contentSheetNavigation] = .settings(inGame: false, showAccount: true)
		case .goOnline:
			if container.has(feature: .accounts) {
				container.appState[\.contentSheetNavigation] = .login
			} else {
				container.interactors.accountInteractor.createGuestAccount(account: nil)
			}
		}
	}

	private func loadMatches() {
		if viewModel.isSpectating {
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
