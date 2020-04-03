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
	case onAppear(Match.ID?)
	case onDisappear
	case refreshMatchDetails
	case modifyOptions
}

class MatchDetailViewModel: ViewModel<MatchDetailViewAction>, ObservableObject {
	@Published private(set) var match: Match?
	@Published private(set) var options: GameOptionData = GameOptionData(options: [])
	@Published var errorLoaf: Loaf?

	private(set) var matchId: Match.ID?
	private var creatingNewMatch: Bool = false

	var gameState: GameState {
		GameState(options: self.options.options)
	}

	var navigationBarTitle: String {
		if let host = match?.host {
			return "\(host.displayName)'s match"
		} else {
			return "New match"
		}
	}

	init(_ match: Match? = nil) {
		self.matchId = match?.id
		self.match = match

		super.init()

		if let match = match {
			self.options.update(with: match.gameOptions)
		}
	}

	override func postViewAction(_ viewAction: MatchDetailViewAction) {
		switch viewAction {
		case .onAppear(let id):
			self.matchId = id
			if matchId == nil {
				createNewMatch()
			} else {
				fetchMatchDetails()
			}
		case .refreshMatchDetails:
			fetchMatchDetails()
		case .onDisappear:
			cleanUp()
		case .modifyOptions:
			break
		}
	}

	private func cleanUp() {
		errorLoaf = nil
		cancelAllRequests()

		if creatingNewMatch {
			#warning("TODO: clean up new match and delete it")
		}
	}

	private func fetchMatchDetails() {
		guard let matchId = matchId else { return }

		HiveAPI
			.shared
			.matchDetails(id: matchId)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						self?.errorLoaf = error.loaf
					}
				},
				receiveValue: { [weak self] match in
					self?.handle(match: match)
				}
			)
			.store(in: self)
	}

	private func createNewMatch() {
		HiveAPI
			.shared
			.createMatch()
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						self?.errorLoaf = error.loaf
					}
				},
				receiveValue: { [weak self] match in
					self?.handle(match: match)
				}
			)
			.store(in: self)
	}

	private func handle(match: Match) {
		self.matchId = match.id
		self.match = match
		errorLoaf = nil
		options.update(with: match.gameOptions)
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
