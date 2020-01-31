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
	case hudFlowState

	var id: String {
		return rawValue
	}
}

enum HiveGameViewAction: BaseViewAction {
	case contentDidLoad(Experience.HiveGame)
	case exitGame
	case arViewError(Error)
}

class HiveGameViewModel: ViewModel<HiveGameViewAction, HiveGameTask>, ObservableObject {
	@Published var handToShow: PlayerHand?
	@Published var informationToPresent: GameInformation?
	@Published var gameState: GameState!
	@Published var errorLoaf: Loaf?

	var flowState = CurrentValueSubject<State, Never>(State.begin)

	var gameAnchor: Experience.HiveGame!

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
		case .contentDidLoad(let game):
			if gameAnchor == nil {
				gameAnchor = game
				transition(to: .gameStart)
			}
		case .exitGame:
			transition(to: .forfeit)
		case .arViewError(let error):
			errorLoaf = Loaf(error.localizedDescription, state: .error)
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

	private func canTransition(from currentState: State, to nextState: State) -> Bool {
		switch (currentState, nextState) {
		case (_, .forfeit): return true
		case (.forfeit, _): return false

		case (.begin, .gameStart): return true
		case (.begin, _): return false
		case (_, .begin): return false
		case (_, .gameStart): return false

		case (.gameStart, .playerTurn), (.gameStart, .opponentTurn): return true
		case (.gameStart, _): return false

		case (.playerTurn, .sendingMovement): return true
		case (.playerTurn, _): return false
		case (.opponentTurn, .receivingMovement): return true
		case (.opponentTurn, _): return false

		case (.sendingMovement, .opponentTurn), (.sendingMovement, .gameEnd): return true
		case (.receivingMovement, .playerTurn), (.receivingMovement, .gameEnd): return true

		case (.sendingMovement, _), (_, .sendingMovement): return false
		case (.receivingMovement, _), (_, .receivingMovement): return false
		case (_, .playerTurn), (_, .opponentTurn): return false

		case (_, .gameEnd): return false
		}
	}
}
