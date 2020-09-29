//
//  GameContentCoordinatorView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI
import HiveEngine

struct GameContentCoordinatorView: View {
	@Environment(\.container) private var container

	@State private var gameSetup: Game.Setup?

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

	private func gameView(_ setup: Game.Setup) -> some View {
		Game(setup: setup)
	}
}

// MARK: - Updates

extension GameContentCoordinatorView {
	var setupUpdates: AnyPublisher<Game.Setup?, Never> {
		container.appState.updates(for: \.gameSetup)
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
	}
}
