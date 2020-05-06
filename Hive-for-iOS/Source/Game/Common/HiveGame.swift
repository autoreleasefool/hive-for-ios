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
	@Environment(\.presentationMode) private var presentationMode
	@Environment(\.container) private var container: AppContainer

	private let onGameEnd: () -> Void
	private let viewModel = HiveGameViewModel()

	init(state: GameState?, player: Player, onGameEnd: @escaping () -> Void) {
		viewModel.playingAs = player
		viewModel.gameStateStore.send(state)
		self.onGameEnd = onGameEnd
	}

	private func handleTransition(to newState: HiveGameViewModel.State) {
		switch newState {
		case .forfeit, .gameEnd:
			presentationMode.wrappedValue.dismiss()
			onGameEnd()
		case .begin, .gameStart, .opponentTurn, .playerTurn, .sendingMovement:
			break
		}
	}

	var body: some View {
		ZStack {
			#if targetEnvironment(simulator)
			Hive2DGame(viewModel: viewModel)
				.edgesIgnoringSafeArea(.all)
			#else
			Hive2DGame(viewModel: viewModel)
				.edgesIgnoringSafeArea(.all)
//			HiveARGame(viewModel: viewModel)
			#endif
			GameHUD()
				.environmentObject(viewModel)
		}
		.onReceive(viewModel.stateStore) { receivedValue in self.handleTransition(to: receivedValue) }
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
}
