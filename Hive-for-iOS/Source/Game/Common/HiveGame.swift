//
//  HiveGame.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine
import Loaf

struct HiveGame: View {
	@Environment(\.presentationMode) var presentationMode
	@EnvironmentObject var viewModel: HiveGameViewModel
	private let stateBuilder: () -> GameState?

	init(stateBuilder: @escaping () -> GameState?) {
		self.stateBuilder = stateBuilder
	}

	private func handleTransition(to newState: HiveGameViewModel.State) {
		switch newState {
		case .forfeit:
			presentationMode.wrappedValue.dismiss()
		case .begin, .gameEnd, .gameStart, .opponentTurn, .playerTurn, .sendingMovement:
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
			GameHUD().environmentObject(viewModel)
		}
		.onReceive(viewModel.flowStateSubject) { receivedValue in self.handleTransition(to: receivedValue) }
		.navigationBarTitle("")
		.navigationBarHidden(true)
		.navigationBarBackButtonHidden(true)
		.onAppear {
			guard let state = self.stateBuilder() else {
				self.viewModel.postViewAction(.failedToStartGame)
				self.presentationMode.wrappedValue.dismiss()
				return
			}

			UIApplication.shared.isIdleTimerDisabled = true
			self.viewModel.postViewAction(.onAppear(state))
		}
		.onDisappear {
			UIApplication.shared.isIdleTimerDisabled = true
			self.viewModel.postViewAction(.onDisappear)
		}
	}
}
