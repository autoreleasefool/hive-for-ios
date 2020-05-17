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
	@Environment(\.container) private var container: AppContainer

	@ObservedObject private var viewModel: LobbyViewModel

	@State var routing = Lobby.Routing()

	init(matches: Loadable<[Match]> = .notLoaded) {
		viewModel = LobbyViewModel(matches: matches)
	}

	var body: some View {
		NavigationView {
			content
				.background(Color(.background).edgesIgnoringSafeArea(.all))
				.navigationBarTitle("Lobby")
				.navigationBarItems(leading: settingsButton, trailing: newMatchButton)
				.onReceive(self.routingUpdate) { self.routing = $0 }
				.onReceive(self.viewModel.actionsPublisher) { self.handleAction($0) }
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
				destination: LobbyRoom(creatingRoom: false),
				isActive: self.inRoom,
				label: { EmptyView() }
			)

			NavigationLink(
				destination: LobbyRoom(creatingRoom: true),
				isActive: self.creatingRoom,
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
}

// MARK: - Actions

extension Lobby {
	var inRoom: Binding<Bool> {
		Binding(
			get: {
				!self.routing.creatingRoom && self.routing.matchId != nil
			},
			set: { newValue in
				guard !newValue else { return }
				self.viewModel.postViewAction(.leaveMatch)
			}
		)
	}

	var creatingRoom: Binding<Bool> {
		Binding(
			get: {
				self.routing.creatingRoom
			},
			set: { newValue in
				guard !newValue else { return }
				self.viewModel.postViewAction(.leaveMatch)
			}
		)
	}

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
		case .openSettings:
			openSettings()
		case .createNewMatch:
			createNewMatch()
		case .leaveMatch:
			leaveMatch()
		case .joinMatch(let id):
			joinMatch(id)
		}
	}

	private func loadMatches() {
		container.interactors.matchInteractor
			.loadOpenMatches(matches: $viewModel.matches)
	}

	private func openSettings() {
		container.appState[\.routing.mainRouting.settingsIsOpen] = true
	}

	private func createNewMatch() {
		container.appState[\.routing.lobbyRouting.creatingRoom] = true
	}

	private func leaveMatch() {
		container.appState[\.routing.lobbyRouting.creatingRoom] = false
		container.appState[\.routing.lobbyRouting.matchId] = nil
	}

	private func joinMatch(_ id: Match.ID) {
		container.appState[\.routing.lobbyRouting.matchId] = id
	}
}

// MARK: - Routing

extension Lobby {
	struct Routing: Equatable {
		var creatingRoom: Bool = false
		var matchId: Match.ID?

		var inRoom: Bool {
			creatingRoom || matchId != nil
		}
	}

	private var routingUpdate: AnyPublisher<Routing, Never> {
		container.appState.updates(for: \.routing.lobbyRouting)
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
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
