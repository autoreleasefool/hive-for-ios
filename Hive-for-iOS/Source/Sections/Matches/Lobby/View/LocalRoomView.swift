//
//  LocalRoomView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-06-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveEngine
import SwiftUI

struct LocalRoomView: View {
	@Environment(\.presentationMode) private var presentationMode
	@Environment(\.toaster) private var toaster
	@Environment(\.container) private var container

	@StateObject private var viewModel: LocalRoomViewModel

	init(opponent: LocalOpponent) {
		_viewModel = StateObject(
			wrappedValue: LocalRoomViewModel(opponent: opponent)
		)
	}

	var body: some View {
		content(viewModel.match)
			.background(Color(.backgroundRegular).edgesIgnoringSafeArea(.all))
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

	private func content(_ match: Match) -> some View {
		RoomDetailsView(
			host: match.host?.summary,
			isHostReady: .notApplicable,
			opponent: match.opponent?.summary,
			isOpponentReady: .notApplicable,
			optionsDisabled: false,
			gameOptionsEnabled: viewModel.gameOptions,
			matchOptionsEnabled: viewModel.matchOptions,
			gameOptionBinding: viewModel.gameOptionEnabled,
			matchOptionBinding: viewModel.optionEnabled
		)
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
			viewModel.postViewAction(.startGame)
		} label: {
			Text("Start")
		}
	}
}

// MARK: - Actions

extension LocalRoomView {
	private func handleAction(_ action: LocalRoomAction) {
		switch action {
		case .startGame:
			startGame()
		case .exitMatch:
			exitMatch()
		case .failedToJoinMatch:
			toaster.loaf.send(LoafState("Failed to start match", state: .error))
			exitMatch()
		}
	}

	private func startGame() {
		let gameState = GameState(options: viewModel.gameOptions)

		switch viewModel.opponent {
		case .human:
			guard let host = viewModel.match.host, let opponent = viewModel.match.opponent else {
				handleAction(.failedToJoinMatch)
				return
			}

			let whitePlayer = viewModel.matchOptions.contains(.hostIsWhite) ? host.id : opponent.id
			let blackPlayer = viewModel.matchOptions.contains(.hostIsWhite) ? opponent.id : host.id
			container.interactors.clientInteractor
				.prepare(.local, clientConfiguration: .local(gameState, whitePlayer: whitePlayer, blackPlayer: blackPlayer))
		case .agent(let configuration):
			container.interactors.clientInteractor
				.prepare(.local, clientConfiguration: .agent(gameState, viewModel.player, configuration))
		}

		container.appState[\.gameSetup] = .init(
			match: viewModel.match,
			state: gameState,
			mode: .play(player: viewModel.player, configuration: .local)
		)
	}

	private func exitMatch() {
		presentationMode.wrappedValue.dismiss()
	}
}

// MARK: - Preview

#if DEBUG
struct LocalRoomViewPreview: PreviewProvider {
	static var previews: some View {
		LocalRoomView(opponent: .agent(.random))
	}
}
#endif
