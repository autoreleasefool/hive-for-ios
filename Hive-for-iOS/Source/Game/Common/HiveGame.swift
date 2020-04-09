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
	@ObservedObject var viewModel: HiveGameViewModel

	init(state: GameState, client: HiveGameClient) {
		viewModel = HiveGameViewModel(client: client)
		viewModel.gameStateSubject.send(state)

		#warning("TODO: set the player based on whether they are host or opponent")
		viewModel.playingAs = .white
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
			#else
			Hive2DGame(viewModel: viewModel)
//			HiveARGame(viewModel: viewModel)
			#endif
			GameHUD().environmentObject(viewModel)
		}
		.onReceive(viewModel.flowStateSubject) { receivedValue in self.handleTransition(to: receivedValue) }
		.edgesIgnoringSafeArea(.all)
		.navigationBarTitle("")
		.navigationBarHidden(true)
		.navigationBarBackButtonHidden(true)
	}
}
