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

	private let viewModel: GameViewModel

	init(setup: Setup) {
		viewModel = GameViewModel(setup: setup)
	}

	private func handleTransition(to newState: GameViewModel.State) {
		switch newState {
		case .shutDown, .forfeit:
			container.appState[\.gameSetup] = nil
		case .begin, .gameStart, .opponentTurn, .playerTurn, .sendingMovement, .gameEnd:
			break
		}
	}

	var body: some View {
		ZStack {
			gameView
				.edgesIgnoringSafeArea(.all)
			GameHUD()
				.environmentObject(viewModel)
				.colorScheme(.dark)
		}
		.onAppear { viewModel.userId = container.account?.userId }
		.onReceive(viewModel.$state) { handleTransition(to: $0) }
		.navigationBarTitle("")
		.navigationBarHidden(true)
		.navigationBarBackButtonHidden(true)
		.onAppear {
			UIApplication.shared.isIdleTimerDisabled = true
			viewModel.userId = container.account?.userId
			viewModel.clientInteractor = container.interactors.clientInteractor
			viewModel.postViewAction(.onAppear)
		}
		.onDisappear {
			UIApplication.shared.isIdleTimerDisabled = true
			viewModel.postViewAction(.onDisappear)
		}
	}

	@ViewBuilder
	private var gameView: some View {
		#if targetEnvironment(simulator)
		GameView2DContainer(viewModel: viewModel)
		#else
		switch container.appState.value.preferences.gameMode {
		case .ar: GameViewARContainer(viewModel: viewModel)
		case .sprite: GameView2DContainer(viewModel: viewModel)
		}
		#endif
	}
}

// MARK: Game Setup

extension Game {
	struct Setup: Equatable {
		let state: GameState
		let mode: Mode
	}
}

extension Game.Setup {
	enum Mode: Equatable {
		case play(player: Player, configuration: ClientInteractorConfiguration)
		case spectate
	}
}
