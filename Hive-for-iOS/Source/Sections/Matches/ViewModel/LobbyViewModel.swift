//
//  LobbyViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Loaf

enum LobbyViewAction: BaseViewAction {
	case onAppear
	case onDisappear
	case refreshMatches
}

class LobbyViewModel: ViewModel<LobbyViewAction>, ObservableObject {
	@Published var errorLoaf: Loaf?

	@Published private(set) var matches: [Match] = [] {
		willSet {
			#warning("TODO: should remove view models for rooms that no longer exist")
			newValue.forEach {
				guard self.matchViewModels[$0.id] == nil else { return }
				self.matchViewModels[$0.id] = MatchDetailViewModel(matchId: $0.id)
			}
		}
	}

	private(set) var matchViewModels: [UUID: MatchDetailViewModel] = [:]

	override func postViewAction(_ viewAction: LobbyViewAction) {
		switch viewAction {
		case .onAppear, .refreshMatches: refreshMatches()
		case .onDisappear: cleanUp()
		}
	}

	private func cleanUp() {
		errorLoaf = nil
		cancelAllRequests()
	}

	private func refreshMatches() {
		HiveAPI
			.shared
			.openMatches()
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						self?.errorLoaf = error.loaf
					}
				},
				receiveValue: { [weak self] matches in
					self?.errorLoaf = nil
					self?.matches = matches
				}
			)
			.store(in: self)
	}
}
