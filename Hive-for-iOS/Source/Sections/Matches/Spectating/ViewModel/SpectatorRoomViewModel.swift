//
//  SpectatorRoomViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-08-20.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation
import HiveEngine

enum SpectatorRoomViewAction: BaseViewAction {
	case onAppear
	case subscribedToClient(AnyPublisher<GameClientEvent, GameClientError>)
	case cancel
	case confirmExit
	case dismissExit
}

enum SpectatorRoomAction: BaseAction {
	case loadMatch(Match.ID)
	case openClientConnection(URL?)
	case startGame(GameState)

	case failedToSpectateMatch
	case matchNotOpenForSpectating
	case exit
}

enum SpectatorRoomCancellable: Int, Identifiable {
	case gameClient

	var id: Int {
		rawValue
	}
}

class SpectatorRoomViewModel: ExtendedViewModel<SpectatorRoomViewAction, SpectatorRoomCancellable>,
															ObservableObject {
	let matchId: Match.ID?

	@Published var match: Loadable<Match> = .notLoaded {
		didSet {
			if let match = match.value {
				openClientConnection(to: match)
			}
		}
	}

	@Published var isCancelling = false

	private let actions = PassthroughSubject<SpectatorRoomAction, Never>()
	var actionsPublisher: AnyPublisher<SpectatorRoomAction, Never> {
		actions.eraseToAnyPublisher()
	}

	init(matchId: Match.ID?, match: Loadable<Match>) {
		self.matchId = matchId
		self.match = match
	}

	override func postViewAction(_ viewAction: SpectatorRoomViewAction) {
		switch viewAction {
		case .onAppear:
			loadMatch()
		case .cancel:
			isCancelling = true
		case .confirmExit:
			cancelSpectating()
		case .dismissExit:
			isCancelling = false
		case .subscribedToClient(let publisher):
			subscribedToClient(publisher)
		}
	}

	private func loadMatch() {
		guard let id = matchId else {
			actions.send(.failedToSpectateMatch)
			return
		}
		actions.send(.loadMatch(id))
	}

	private func updateGameState(to state: GameState) {
		cancel(withId: .gameClient)
		actions.send(.startGame(state))
	}

	private func cancelSpectating() {
		cancel(withId: .gameClient)
		actions.send(.exit)
	}
}

// MARK: GameClient

extension SpectatorRoomViewModel {
	private func openClientConnection(to match: Match) {
		if let url = match.webSocketSpectatingUrl {
			openClientConnection(to: url)
		} else {
			actions.send(.failedToSpectateMatch)
		}
	}

	private func openClientConnection(to url: URL?) {
		actions.send(.openClientConnection(url))
	}

	private func subscribedToClient(_ publisher: AnyPublisher<GameClientEvent, GameClientError>) {
		// Unsubscribe so we don't get multiple messages
		cancel(withId: .gameClient)

		publisher
			.sink(
				receiveCompletion: {
					if case let .failure(error) = $0 {
						self.handleGameClientError(error)
					}
				}, receiveValue: {
					self.handleGameClientEvent($0)
				}
			)
			.store(in: self, withId: .gameClient)
	}

	private func handleGameClientError(_ error: GameClientError) {
		actions.send(.failedToSpectateMatch)
	}

	private func handleGameClientEvent(_ event: GameClientEvent) {
		switch event {
		case .connected, .alreadyConnected:
			break
		case .message(let message):
			handleGameClientMessage(message)
		}
	}

	private func handleGameClientMessage(_ message: GameServerMessage) {
		switch message {
		case .gameState(let state):
			updateGameState(to: state)
		case .forfeit, .gameOver:
			actions.send(.matchNotOpenForSpectating)
		case .error, .playerJoined, .playerLeft, .playerReady, .setOption, .message,
				 .spectatorJoined, .spectatorLeft:
			break
		}
	}
}
