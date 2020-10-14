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

	init(opponent: AgentConfiguration) {
		_viewModel = StateObject(
			wrappedValue: LocalRoomViewModel(opponent: opponent)
		)
	}

	var body: some View {
		content
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

	// MARK: Content

	@ViewBuilder
	private var content: some View {
		switch viewModel.match {
		case .notLoaded: notLoadedView
		case .loaded(let match): loadedView(match)
		case .loading, .failed: errorView
		}
	}

	private var notLoadedView: some View {
		Text("").onAppear { viewModel.postViewAction(.createMatch) }
	}

	private func loadedView(_ match: Match) -> some View {
		RoomDetailsView(
			host: match.host?.summary,
			hostIsReady: false,
			opponent: match.opponent?.summary,
			opponentIsReady: false,
			optionsDisabled: false,
			gameOptionsEnabled: viewModel.gameOptions,
			matchOptionsEnabled: viewModel.matchOptions,
			gameOptionBinding: viewModel.gameOptionEnabled,
			matchOptionBinding: viewModel.optionEnabled
		)
	}

	private var errorView: some View {
		EmptyState(
			header: "An error occurred",
			message: "We can't create this match right now.",
			action: .init(text: "Refresh") { viewModel.postViewAction(.createMatch) }
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
		}
	}

	private func startGame() {
		let gameState = GameState(options: viewModel.gameOptions)

		container.interactors.clientInteractor
			.prepare(.local, clientConfiguration: .offline(gameState, viewModel.player, viewModel.opponent))
		container.appState[\.gameSetup] = .init(
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
		LocalRoomView(opponent: .random)
	}
}
#endif
