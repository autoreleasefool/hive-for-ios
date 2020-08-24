//
//  LocalRoom.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-06-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveEngine
import SwiftUI

struct LocalRoom: View {
	@Environment(\.presentationMode) private var presentationMode
	@Environment(\.toaster) private var toaster
	@Environment(\.container) private var container

	@ObservedObject private var viewModel = LocalRoomViewModel()

	init(opponent: AgentConfiguration) {
		viewModel.opponent = opponent
	}

	var body: some View {
		content
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

	// MARK: Content

	private var content: AnyView {
		switch viewModel.match {
		case .notLoaded: return AnyView(notLoadedView)
		case .loaded(let match): return AnyView(loadedView(match))
		case .loading, .failed: return AnyView(errorView)
		}
	}

	private var notLoadedView: some View {
		Text("").onAppear { self.viewModel.postViewAction(.createMatch) }
	}

	private func loadedView(_ match: Match) -> some View {
		RoomDetails(
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
			action: .init(text: "Refresh") { self.viewModel.postViewAction(.createMatch) }
		)
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
			self.viewModel.postViewAction(.startGame)
		}, label: {
			Text("Start")
		})
	}
}

// MARK: - Actions

extension LocalRoom {
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
		container.appState[\.gameSetup] = .init(state: gameState, mode: .play(player: viewModel.player, configuration: .local))
	}

	private func exitMatch() {
		presentationMode.wrappedValue.dismiss()
	}
}
