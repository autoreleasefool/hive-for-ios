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
			if viewModel.hasGameEnded || viewModel.isSpectating {
				returnToLobbyButton
			}
			rulesButton
			settingsButton
			if !viewModel.hasGameEnded && !viewModel.isSpectating {
				forfeitButton
			}
		}
	}

	private var returnToLobbyButton: some View {
		PrimaryButton("Return to lobby") {
			viewModel.postViewAction(.closeInformation(withFeedback: true))
			viewModel.postViewAction(.returnToLobby)
		}
	}

	private var rulesButton: some View {
		PrimaryButton("Game rules") {
			viewModel.postViewAction(.presentInformation(.rule(nil)))
		}
	}

	private var settingsButton: some View {
		PrimaryButton("Settings") {
			viewModel.postViewAction(.openAppSettings)
		}
	}

	private var forfeitButton: some View {
		PrimaryButton("Forfeit") {
			viewModel.postViewAction(.closeInformation(withFeedback: true))
			viewModel.postViewAction(.forfeit)
		}
	}
}
