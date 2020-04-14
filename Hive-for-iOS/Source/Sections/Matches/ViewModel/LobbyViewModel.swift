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
import WebSocketKit

enum LobbyViewAction: BaseViewAction {
	case onAppear
	case onDisappear
	case refreshMatches
}

class LobbyViewModel: ViewModel<LobbyViewAction>, ObservableObject {
	@Published var errorLoaf: Loaf?

	@Published private(set) var matches: [Match] = []

	let client = WebSocketClient(eventLoopGroupProvider: .createNew)

	override func postViewAction(_ viewAction: LobbyViewAction) {
		switch viewAction {
		case .onAppear, .refreshMatches:
			refreshMatches()
		case .onDisappear:
			cleanUp()
		}
	}

	private func cleanUp() {
		try? client.syncShutdown()
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
