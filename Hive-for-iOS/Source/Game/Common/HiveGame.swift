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
	}

	var body: some View {
		ZStack {
			HiveARGame(viewModel: $viewModel)
			GameHUD().environmentObject(viewModel)
		}
		.onReceive(viewModel.exitedGame) { _ in self.presentationMode.wrappedValue.dismiss() }
		.edgesIgnoringSafeArea(.all)
		.navigationBarTitle("")
		.navigationBarHidden(true)
		.loaf($viewModel.errorLoaf)
	}
}
