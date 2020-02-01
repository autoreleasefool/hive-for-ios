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
	@State var viewModel = HiveGameViewModel()

	init(state: GameState) {
		viewModel.gameState = state

		#warning("TODO: set the player based on whether they are host or opponent")
		viewModel.playingAs = .white
	}

	private func handleTransition(to newState: HiveGameViewModel.State) {
		switch newState {
		case .forfeit:
			presentationMode.wrappedValue.dismiss()
		case .begin, .gameEnd, .gameStart, .opponentTurn, .playerTurn, .sendingMovement, .receivingMovement:
			break
		}
	}

	var body: some View {
		ZStack {
			HiveARGame(viewModel: $viewModel)
			GameHUD().environmentObject(viewModel)
		}
		.onReceive(viewModel.flowState) { receivedValue in self.handleTransition(to: receivedValue) }
		.edgesIgnoringSafeArea(.all)
		.navigationBarTitle("")
		.navigationBarHidden(true)
		.loaf($viewModel.errorLoaf)
	}
}
