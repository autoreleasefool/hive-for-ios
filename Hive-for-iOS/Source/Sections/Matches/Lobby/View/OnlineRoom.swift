//
//  OnlineRoom.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI
import HiveEngine

struct OnlineRoom: View {
	@Environment(\.presentationMode) private var presentationMode
	@Environment(\.toaster) private var toaster
	@Environment(\.container) private var container

	@ObservedObject private var viewModel: OnlineRoomViewModel

	init(id: Match.ID?, creatingNewMatch: Bool, match: Loadable<Match> = .notLoaded) {
		self.viewModel = OnlineRoomViewModel(matchId: id, creatingNewMatch: creatingNewMatch, match: match)
	}

	var body: some View {
		GeometryReader { geometry in
			self.content(geometry)
		}
		.background(Color(.background).edgesIgnoringSafeArea(.all))
		.navigationBarTitle(Text(viewModel.title), displayMode: .inline)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: exitButton, trailing: startButton)
		.onReceive(viewModel.actionsPublisher) { self.handleAction($0) }
		.popoverSheet(isPresented: $viewModel.exiting) {
			PopoverSheetConfig(
				title: "Leave match?",
				message: "Are you sure you want to leave this match?",
				buttons: [
					PopoverSheetConfig.ButtonConfig(title: "Leave", type: .destructive) {
						self.viewModel.postViewAction(.exitMatch)
					},
					PopoverSheetConfig.ButtonConfig(title: "Stay", type: .cancel) {
						self.viewModel.postViewAction(.dismissExit)
					},
				]
			)
		}
	}

	private func content(_ geometry: GeometryProxy) -> AnyView {
		switch viewModel.match {
		case .notLoaded: return AnyView(notLoadedView)
		case .loading(let match, _): return AnyView(loadedView(match, geometry))
		case .loaded(let match): return AnyView(loadedView(match, geometry))
		case .failed(let error): return AnyView(failedView(error))
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.onAppear { self.viewModel.postViewAction(.onAppear(self.container.account?.userId)) }
	}

	private func loadedView(_ match: Match?, _ geometry: GeometryProxy) -> some View {
		ScrollView {
			if match == nil {
				HStack {
					Spacer()
					ActivityIndicator(isAnimating: true, style: .whiteLarge)
					Spacer()
				}
				.padding(.top, length: .m)
				.frame(width: geometry.size.width)
			} else {
				if self.viewModel.reconnecting {
					reconnectingView(geometry)
				} else {
					matchDetail(match!)
				}
			}
		}
	}

	private func failedView(_ error: Error) -> some View {
		EmptyState(
			header: "An error occurred",
			message: "We can't fetch the match right now.\n\(viewModel.errorMessage(from: error))",
			action: .init(text: "Refresh") { self.viewModel.postViewAction(.retryInitialAction) }
		)
	}

	private func reconnectingView(_ geometry: GeometryProxy) -> some View {
		VStack(spacing: .m) {
			Text("The connection to the server was lost.\nPlease wait while we try to reconnect you.")
				.multilineTextAlignment(.center)
				.body()
				.foregroundColor(Color(.text))
			ActivityIndicator(isAnimating: true, style: .whiteLarge)
			Text(viewModel.reconnectingMessage)
				.multilineTextAlignment(.center)
				.body()
				.foregroundColor(Color(.text))
			Spacer()
		}
		.padding(.all, length: .m)
		.padding(.top, length: .xl)
		.frame(width: geometry.size.width)
	}

	// MARK: Buttons

	private var exitButton: some View {
		Button(action: {
			self.viewModel.postViewAction(.requestExit)
		}, label: {
			Text("Leave")
		})
	}

	private var startButton: some View {
		Button(action: {
			self.viewModel.postViewAction(.toggleReadiness)
		}, label: {
			Text(viewModel.startButtonText)
		})
	}

	// MARK: Match Detail

	private func matchDetail(_ match: Match) -> some View {
		RoomDetails(
			host: match.host?.summary,
			hostIsReady: viewModel.isPlayerReady(id: match.host?.id),
			opponent: match.opponent?.summary,
			opponentIsReady: viewModel.isPlayerReady(id: match.opponent?.id),
			optionsDisabled: !viewModel.userIsHost,
			gameOptionsEnabled: viewModel.gameOptions,
			matchOptionsEnabled: viewModel.matchOptions,
			gameOptionBinding: viewModel.gameOptionEnabled,
			matchOptionBinding: viewModel.optionEnabled
		)
	}
}

// MARK: - Actions

extension OnlineRoom {
	private func handleAction(_ action: OnlineRoomAction) {
		switch action {
		case .createNewMatch:
			createNewMatch()
		case .joinMatch:
			joinMatch()
		case .loadMatchDetails:
			loadMatchDetails()
		case .startGame(let state, let player):
			startGame(state: state, player: player)

		case .openClientConnection(let url):
			openClientConnection(to: url)
		case .closeConnection:
			close()
		case .sendMessage(let message):
			send(message)

		case .failedToJoinMatch:
			failedToJoin()
		case .failedToReconnect:
			failedToReconnect()
		case .exitSilently:
			exitSilently()
		case .exitMatch:
			exitMatch()

		case .showLoaf(let loaf):
			toaster.loaf.send(loaf)
		}
	}

	private func startGame(state: GameState, player: Player) {
		container.appState[\.gameSetup] = Game.Setup(
			state: state,
			mode: .play(player: player, configuration: .online)
		)
	}

	private func joinMatch() {
		guard let id = viewModel.initialMatchId else { return }
		container.interactors.matchInteractor
			.joinMatch(id: id, match: $viewModel.match)
	}

	private func createNewMatch() {
		container.interactors.matchInteractor
			.createNewMatch(match: $viewModel.match)
	}

	private func loadMatchDetails() {
		guard let id = viewModel.match.value?.id else { return }
		container.interactors.matchInteractor
			.loadMatchDetails(id: id, match: $viewModel.match)
	}

	private func failedToJoin() {
		toaster.loaf.send(LoafState("Failed to join match", state: .error))
		presentationMode.wrappedValue.dismiss()
	}

	private func failedToReconnect() {
		toaster.loaf.send(LoafState("Failed to reconnect", state: .error))
		presentationMode.wrappedValue.dismiss()
	}

	private func exitSilently() {
		presentationMode.wrappedValue.dismiss()
	}

	private func exitMatch() {
		send(.forfeit)
		close()
		presentationMode.wrappedValue.dismiss()
	}
}

// MARK: - GameClient

extension OnlineRoom {
	private func openClientConnection(to url: URL?) {
		let publisher: AnyPublisher<GameClientEvent, GameClientError>
		if let url = url {
			container.interactors.clientInteractor
				.prepare(.online, clientConfiguration: .online(url, container.account))
			publisher = container.interactors.clientInteractor
				.openConnection(.online)
		} else {
			publisher = container.interactors.clientInteractor
				.reconnect(.online)
		}

		viewModel.postViewAction(.subscribedToClient(publisher))
	}

	private func send(_ message: GameClientMessage) {
		container.interactors.clientInteractor
			.send(.online, message, completionHandler: nil)
	}

	private func close() {
		container.interactors.clientInteractor
			.close(.online)
	}
}

#if DEBUG
struct OnlineRoomPreview: PreviewProvider {
	static var previews: some View {
		return OnlineRoom(
			id: Match.matches[0].id,
			creatingNewMatch: false,
			match: .loaded(Match.matches[0])
		)
	}
}
#endif
