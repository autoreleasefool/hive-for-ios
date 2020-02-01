//
//  HiveGameViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine
import HiveEngine
import Loaf

enum HiveGameTask: String, Identifiable {
	case viewFlowState

	var id: String {
		return rawValue
	}
}

enum HiveGameViewAction: BaseViewAction {
	case viewContentDidLoad(GameViewContent)
	case viewContentReady

	case exitGame
	case arViewError(Error)
}

class HiveGameViewModel: ViewModel<HiveGameViewAction, HiveGameTask>, ObservableObject {
	@Published var handToShow: PlayerHand?
	@Published var informationToPresent: GameInformation?
	@Published var gameState: GameState!
	@Published var errorLoaf: Loaf?

	var flowState = CurrentValueSubject<State, Never>(State.begin)
	var gameContent: GameViewContent!

	var gameAnchor: Experience.HiveGame? {
		guard let gameContent = gameContent else { return nil }
		if case let .arExperience(anchor) = gameContent {
			return anchor
		} else {
			return nil
		}
	}

	var showPlayerHand: Binding<Bool> {
		return Binding(
			get: { self.handToShow != nil },
			set: { _ in self.handToShow = nil }
		)
	}

	var hasInformation: Binding<Bool> {
		return Binding(
			get: { self.informationToPresent != nil },
			set: { _ in self.informationToPresent = nil }
		)
	}

	override func postViewAction(_ viewAction: HiveGameViewAction) {
		switch viewAction {
		case .viewContentDidLoad(let content):
			if gameContent == nil {
				self.gameContent = content
				transition(to: .gameStart)
			}
		case .viewContentReady:
			setupNewGame()
		case .exitGame:
			transition(to: .forfeit)
		case .arViewError(let error):
			errorLoaf = Loaf(error.localizedDescription, state: .error)
		}
	}

	private func setupNewGame() {
		#warning("TODO: check against the player's actual color")
		if gameState.currentPlayer == .white {
			transition(to: .playerTurn)
		} else {
			transition(to: .opponentTurn)
		}
	}
}

// MARK: - State

extension HiveGameViewModel {
	enum State: Equatable {
		case begin
		case gameStart
		case playerTurn
		case opponentTurn
		case sendingMovement(Movement)
		case receivingMovement(Movement)
		case gameEnd
		case forfeit
	}

	func transition(to nextState: State) {
		guard canTransition(from: flowState.value, to: nextState) else { return }
		flowState.send(nextState)
	}

	// swiftlint:disable cyclomatic_complexity

	private func canTransition(from currentState: State, to nextState: State) -> Bool {
		switch (currentState, nextState) {

		// Forfeiting possible at any time
		case (_, .forfeit): return true
		case (.forfeit, _): return false

		// Beginning the game always transitions to the start of a game
		case (.begin, .gameStart): return true
		case (.begin, _): return false
		case (_, .begin): return false
		case (_, .gameStart): return false

		// The start of a game leads to a player's turn or an opponent's turn
		case (.gameStart, .playerTurn), (.gameStart, .opponentTurn): return true
		case (.gameStart, _): return false

		// The player must send moves, and opponent's moves must be received
		case (.playerTurn, .sendingMovement): return true
		case (.playerTurn, _): return false
		case (.opponentTurn, .receivingMovement): return true
		case (.opponentTurn, _): return false

		// A played move either leads to a new turn, or the end of the game
		case (.sendingMovement, .opponentTurn), (.sendingMovement, .gameEnd): return true
		case (.receivingMovement, .playerTurn), (.receivingMovement, .gameEnd): return true

		case (.sendingMovement, _), (_, .sendingMovement): return false
		case (.receivingMovement, _), (_, .receivingMovement): return false
		case (_, .playerTurn), (_, .opponentTurn): return false

		case (_, .gameEnd): return false
		}
	}

	// swiftlint:enable cyclomatic_complexity
}
