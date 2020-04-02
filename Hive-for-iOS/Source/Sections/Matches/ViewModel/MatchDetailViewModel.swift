//
//  MatchDetailViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Loaf
import HiveEngine

enum MatchDetailViewAction: BaseViewAction {
	case onAppear
	case onDisappear
	case refreshMatchDetails
	case modifyOptions
}

class MatchDetailViewModel: ViewModel<MatchDetailViewAction>, ObservableObject {
	@Published private(set) var match: Match?
	@Published private(set) var options: GameOptionData = GameOptionData(options: [])
	@Published var errorLoaf: Loaf?

	let matchId: UUID

	var gameState: GameState {
		GameState(options: self.options.options)
	}

	init(matchId: UUID) {
		self.matchId = matchId
	}

	init(match: Match) {
		self.matchId = match.id
		self.match = match

		super.init()

		self.options.update(with: match.gameOptions)
	}

	override func postViewAction(_ viewAction: MatchDetailViewAction) {
		switch viewAction {
		case .onAppear, .refreshMatchDetails:
			fetchMatchDetails()
		case .onDisappear: cleanUp()
		case .modifyOptions: break
		}
	}

	private func cleanUp() {
		errorLoaf = nil
		cancelAllRequests()
	}

	private func fetchMatchDetails() {
		HiveAPI
			.shared
			.match(id: matchId)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						self?.errorLoaf = error.loaf
					}
				},
				receiveValue: { [weak self] match in
					self?.errorLoaf = nil
					self?.match = match
					self?.options.update(with: match.gameOptions)
				}
			)
			.store(in: self)
	}
}

final class GameOptionData: ObservableObject {
	private(set) var options: Set<GameState.Option>

	init(options: Set<GameState.Option>) {
		self.options = options
	}

	func update(with: Set<GameState.Option>) {
		self.options = with
	}

	func binding(for option: GameState.Option) -> Binding<Bool> {
		Binding(get: {
			self.options.contains(option)
		}, set: {
			if $0 {
				self.options.insert(option)
			} else {
				self.options.remove(option)
			}
		})
	}
}
