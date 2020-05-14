//
//  GameContentCoordinator.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct GameContentCoordinator: View {
	@Environment(\.container) private var container: AppContainer

	@State private var routing = Routing()

	var body: some View {
		content
	}

	var content: AnyView {
		if let setup = routing.gameSetup {
			return AnyView(gameView(setup))
		} else {
			return AnyView(contentView)
		}
	}

	// MARK: - Content

	private var contentView: some View {
		RootTabView()
	}

	private func gameView(_ setup: GameSetup) -> some View {
		HiveGame(state: setup.state, player: setup.player)
	}
}

// MARK: - Routing

extension GameContentCoordinator {
	struct Routing: Equatable {
		var gameSetup: GameSetup?
	}

	struct GameSetup: Equatable {
		let state: GameState
		let player: Player
	}
}
