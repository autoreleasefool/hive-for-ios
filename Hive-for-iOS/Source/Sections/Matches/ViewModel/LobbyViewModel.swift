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
	@Published private(set) var matches: [Match] = []

	private(set) var newMatchViewModel = MatchDetailViewModel(id: nil)
	private(set) var detailViewModels: [Match.ID: MatchDetailViewModel] = [:]

	private(set) var refreshComplete = PassthroughSubject<Void, Never>()

	private var api: HiveAPI!

	override func postViewAction(_ viewAction: LobbyViewAction) {
		switch viewAction {
		case .onAppear, .refreshMatches:
			refreshMatches()
		case .onDisappear:
			cancelAllRequests()
		}
	}

	private func refreshMatches() {
		api.openMatches()
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					self?.refreshComplete.send()
					if case let .failure(error) = result {
						self?.errorLoaf = error.loaf
					}
				},
				receiveValue: { [weak self] matches in
					guard let self = self else { return }
					matches.forEach {
						self.detailViewModels[$0.id] = MatchDetailViewModel(match: $0)
					}
					self.errorLoaf = nil
					self.matches = matches
				}
			)
			.store(in: self)
	}

	func setAPI(to api: HiveAPI) {
		self.api = api
	}
}
