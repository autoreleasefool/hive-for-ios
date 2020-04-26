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
	@Environment(\.presentationMode) var presentationMode
	@EnvironmentObject var viewModel: HiveGameViewModel
	private let onGameEnd: () -> Void

	init(onGameEnd: @escaping () -> Void) {
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
			GameHUD().environmentObject(viewModel)
		}
		.onReceive(viewModel.stateStore) { receivedValue in self.handleTransition(to: receivedValue) }
		.navigationBarTitle("")
		.navigationBarHidden(true)
		.navigationBarBackButtonHidden(true)
		.onAppear {
			UIApplication.shared.isIdleTimerDisabled = true
			self.viewModel.postViewAction(.onAppear)
		}
		.onDisappear {
			UIApplication.shared.isIdleTimerDisabled = true
			self.viewModel.postViewAction(.onDisappear)
		}
	}
}
