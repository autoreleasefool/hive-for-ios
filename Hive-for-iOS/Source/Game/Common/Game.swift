//
//  Game.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine
import HiveEngine
import Loaf

struct Game: View {
	@Environment(\.container) private var container

	@StateObject private var viewModel: GameViewModel

	private var playerViewModel: PlayerGameViewModel? {
		viewModel as? PlayerGameViewModel
	}

	private var spectatorViewModel: SpectatorGameViewModel? {
		viewModel as? SpectatorGameViewModel
	}

	init(setup: Setup) {
		switch setup.mode {
		case .singlePlayer, .twoPlayer
		: _viewModel = StateObject(wrappedValue: PlayerGameViewModel(setup: setup))
		case .spectate:
			_viewModel = StateObject(wrappedValue: SpectatorGameViewModel(setup: setup))
		}
	}

	var body: some View {
		ZStack {
			gameView
				.edgesIgnoringSafeArea(.all)
			GameHUD()
				.environmentObject(viewModel)
		}
		.onReceive(viewModel.actionsPublisher) { handleAction($0) }
		.onAppear {
			UIApplication.shared.isIdleTimerDisabled = true
			viewModel.postViewAction(
				.onAppear(
					container.account?.id,
					container.interactors.clientInteractor,
					container.preferences
				)
			)
		}
		.onDisappear {
			UIApplication.shared.isIdleTimerDisabled = false
			viewModel.postViewAction(.onDisappear)
		}
	}

	@ViewBuilder
	private var gameView: some View {
		#if targetEnvironment(simulator)
		GameView2DContainer(viewModel: viewModel)
		#else
		switch container.preferences.gameMode {
		case .ar: GameViewARContainer(viewModel: viewModel)
		case .sprite: GameView2DContainer(viewModel: viewModel)
		}
		#endif
	}
}

// MARK: Actions

extension Game {
	private func handleAction(_ action: GameAction) {
		switch action {
		case .endGame:
			container.appState[\.gameSetup] = nil
		case .showAppSettings:
			container.appState.value.setNavigation(to: .settings(inGame: true, showAccount: false))
		}
	}
}

// MARK: Game Setup

extension Game {
	struct Setup: Equatable {
		let match: Match
		let state: GameState
		let mode: Mode
	}
}

extension Game.Setup {
	enum Mode: Equatable {
		case singlePlayer(player: Player, configuration: ClientInteractorConfiguration)
		case twoPlayer
		case spectate
	}
}
