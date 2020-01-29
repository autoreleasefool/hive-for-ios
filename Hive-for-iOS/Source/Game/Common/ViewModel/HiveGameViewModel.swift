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

enum HiveGameTask: Identifiable {
	var id: String {
		return ""
	}
}

enum HiveGameViewAction: BaseViewAction {
	case contentDidLoad
	case exitGame
	case arViewError(Error)
}

class HiveGameViewModel: ViewModel<HiveGameViewAction, HiveGameTask>, ObservableObject {
	@Published var handToShow: PlayerHand?
	@Published var informationToPresent: GameInformation?
	@Published var gameState: GameState!
	@Published var errorLoaf: Loaf?
	var exitedGame = PassthroughSubject<Void, Never>()

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
		case .contentDidLoad:
			break
		case .exitGame:
			self.exitedGame.send()
		case .arViewError(let error):
			self.errorLoaf = Loaf(error.localizedDescription, state: .error)
		}
	}
}
