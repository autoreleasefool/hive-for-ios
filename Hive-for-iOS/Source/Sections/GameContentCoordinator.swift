//
//  GameContentCoordinator.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI
import HiveEngine

struct GameContentCoordinator: View {
	@Environment(\.container) private var container

	@State private var gameSetup: GameSetup?

	var body: some View {
		content
			.onReceive(setupUpdates) { self.gameSetup = $0 }
	}

	var content: AnyView {
		if let setup = gameSetup {
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
		HiveGame(state: setup.state, player: setup.player, mode: setup.mode)
	}
}

// MARK: - GameSetup

extension GameContentCoordinator {
	struct GameSetup: Equatable {
		let state: GameState
		let player: Player
		let mode: ClientInteractorConfiguration
	}
}

// MARK: - Updates

extension GameContentCoordinator {
	var setupUpdates: AnyPublisher<GameSetup?, Never> {
		container.appState.updates(for: \.gameSetup)
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
	}
}
