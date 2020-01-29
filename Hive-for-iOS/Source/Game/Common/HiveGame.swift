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
	@Binding var gameIsActive: Bool
	@State var viewModel = HiveGameViewModel()

	init(isActive: Binding<Bool>, state: GameState) {
		_gameIsActive = isActive
		viewModel.gameState = state
	}

	var body: some View {
		ZStack {
			HiveARGame(shouldBePresented: $gameIsActive, viewModel: $viewModel)
			GameHUD()
				.environmentObject(viewModel)
		}
		.edgesIgnoringSafeArea(.all)
		.navigationBarTitle("")
		.navigationBarHidden(true)
		.loaf($viewModel.errorLoaf)
	}
}
