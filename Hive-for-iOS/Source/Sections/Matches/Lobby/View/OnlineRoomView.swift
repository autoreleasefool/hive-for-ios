//
//  OnlineRoomView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI
import HiveEngine

struct OnlineRoomView: View {
	@Environment(\.presentationMode) private var presentationMode
	@Environment(\.toaster) private var toaster
	@Environment(\.container) private var container

	@StateObject private var viewModel: OnlineRoomViewModel

	init(id: Match.ID?, creatingNewMatch: Bool, match: Loadable<Match> = .notLoaded) {
		_viewModel = StateObject(
			wrappedValue: OnlineRoomViewModel(
				matchId: id,
				creatingNewMatch: creatingNewMatch,
				match: match
			)
		)
	}

	var body: some View {
		content
			.navigationBarTitle(Text(viewModel.title), displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(leading: exitButton, trailing: startButton)
			.onReceive(viewModel.actionsPublisher) { handleAction($0) }
			.popoverSheet(isPresented: $viewModel.exiting) {
				PopoverSheetConfig(
					title: "Leave match?",
					message: "Are you sure you want to leave this match?",
					buttons: [
						PopoverSheetConfig.ButtonConfig(title: "Leave", type: .destructive) {
							viewModel.postViewAction(.exitMatch)
						},
						PopoverSheetConfig.ButtonConfig(title: "Stay", type: .cancel) {
							viewModel.postViewAction(.dismissExit)
						},
					]
				)
			}
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.match {
		case .notLoaded: notLoadedView
		case .loading(let match, _): loadedView(match)
		case .loaded(let match): loadedView(match)
		case .failed(let error): failedView(error)
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.background(Color(.backgroundRegular).edgesIgnoringSafeArea(.all))
			.onAppear { viewModel.postViewAction(.onAppear(container.account?.userId)) }
	}

	@ViewBuilder
	private func loadedView(_ match: Match?) -> some View {
		if match == nil {
			LoadingView()
		} else {
			if viewModel.reconnecting {
				reconnectingView
			} else {
				matchDetail(match!)
			}
		}
	}

	private func failedView(_ error: Error) -> some View {
		EmptyState(
			header: "An error occurred",
			message: "We can't fetch the match right now.\n\(viewModel.errorMessage(from: error))",
			action: EmptyState.Action(text: "Refresh") { viewModel.postViewAction(.retryInitialAction) }
		)
	}

	private var reconnectingView: some View {
		LoadingView("The connection to the server was lost.\nPlease wait while we try to reconnect you")
	}

	// MARK: Buttons

	private var exitButton: some View {
		Button {
			viewModel.postViewAction(.requestExit)
		} label: {
			Text("Leave")
		}
	}

	private var startButton: some View {
		Button {
			viewModel.postViewAction(.toggleReadiness)
		} label: {
			Text(viewModel.startButtonText)
		}
	}

	// MARK: Match Detail

	private func matchDetail(_ match: Match) -> some View {
		RoomDetailsView(
			host: match.host?.summary,
			isHostReady: RoomDetailsView.ReadyStatus(viewModel.isPlayerReady(id: match.host?.id)),
			opponent: match.opponent?.summary,
			isOpponentReady: RoomDetailsView.ReadyStatus(viewModel.isPlayerReady(id: match.opponent?.id)),
			optionsDisabled: !viewModel.userIsHost,
			gameOptionsEnabled: viewModel.gameOptions,
			matchOptionsEnabled: viewModel.matchOptions,
			gameOptionBinding: viewModel.gameOptionEnabled,
			matchOptionBinding: viewModel.optionEnabled
		)
	}
}

// MARK: - Actions

extension OnlineRoomView {
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
		guard let match = viewModel.match.value else {
			handleAction(.failedToJoinMatch)
			return
		}
		container.appState[\.gameSetup] = Game.Setup(
			match: match,
			state: state,
			mode: .singlePlayer(player: player, configuration: .online)
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
		toaster.loaf.send(LoafState("Failed to join match", style: .error()))
		presentationMode.wrappedValue.dismiss()
	}

	private func failedToReconnect() {
		toaster.loaf.send(LoafState("Failed to reconnect", style: .error()))
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

extension OnlineRoomView {
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

// MARK: - Preview

#if DEBUG
struct OnlineRoomPreview: PreviewProvider {
	static var previews: some View {
		return OnlineRoomView(
			id: Match.matches[0].id,
			creatingNewMatch: false,
			match: .loaded(Match.matches[0])
		)
	}
}
#endif
