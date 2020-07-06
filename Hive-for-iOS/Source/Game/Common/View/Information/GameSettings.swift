//
//  GameSettings.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-05.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct GameSettings: View {
	@EnvironmentObject var viewModel: GameViewModel

	var body: some View {
		VStack(spacing: .m) {
			if viewModel.gameState.hasGameEnded {
				returnToLobbyButton
			} else {
				forfeitButton
			}
			Divider().background(Color(.divider))
			closeButton
		}
	}

	private var returnToLobbyButton: some View {
		BasicButton<Never>("Return to lobby") {
			self.viewModel.presentingGameInformation.wrappedValue = false
			self.viewModel.postViewAction(.returnToLobby)
		}
	}

	private var forfeitButton: some View {
		BasicButton<Never>("Forfeit") {
			self.viewModel.presentingGameInformation.wrappedValue = false
			self.viewModel.postViewAction(.forfeit)
		}
	}

	private var closeButton: some View {
		BasicButton<Never>("Close") {
			self.viewModel.presentingGameInformation.wrappedValue = false
		}
		.buttonBackground(.backgroundLight)
	}
}
