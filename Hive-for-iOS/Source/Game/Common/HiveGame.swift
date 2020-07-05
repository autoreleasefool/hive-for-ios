//
//  HiveGame.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine
import HiveEngine
import Loaf

struct HiveGame: View {
	@Environment(\.container) private var container

	private let viewModel: HiveGameViewModel

	init(state: GameState, player: Player, mode: ClientInteractorConfiguration) {
		viewModel = HiveGameViewModel(initialState: state, playingAs: player, mode: mode)
	}

	private func handleTransition(to newState: HiveGameViewModel.State) {
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
		}
		.onAppear { self.viewModel.userId = self.container.account?.userId }
		.onReceive(viewModel.stateStore) { self.handleTransition(to: $0) }
		.navigationBarTitle("")
		.navigationBarHidden(true)
		.navigationBarBackButtonHidden(true)
		.onAppear {
			UIApplication.shared.isIdleTimerDisabled = true
			self.viewModel.userId = self.container.account?.userId
			self.viewModel.clientInteractor = self.container.interactors.clientInteractor
			self.viewModel.postViewAction(.onAppear)
		}
		.onDisappear {
			UIApplication.shared.isIdleTimerDisabled = true
			self.viewModel.postViewAction(.onDisappear)
		}
	}

	private var gameView: AnyView {
		#if targetEnvironment(simulator)
		return AnyView(Hive2DGame(viewModel: viewModel))
		#else
		switch container.appState.value.preferences.gameMode {
		case .ar: return AnyView(HiveARGame(viewModel: viewModel))
		case .sprite: return AnyView(Hive2DGame(viewModel: viewModel))
		}
		#endif
	}
}
