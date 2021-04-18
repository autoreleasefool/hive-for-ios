//
//  OnlineRoomViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation
import HiveEngine
import HiveFoundation
import SwiftUI

enum OnlineRoomViewAction: BaseViewAction {
	case onAppear(User.ID?)
	case retryInitialAction
	case refresh

	case requestExit
	case dismissExit
	case exitMatch

	case subscribedToClient(AnyPublisher<GameClientEvent, GameClientError>)

	case toggleReadiness
}

enum OnlineRoomAction: BaseAction {
	case createNewMatch
	case joinMatch
	case loadMatchDetails
	case startGame(GameState, Player)

	case openClientConnection(URL?)
	case closeConnection
	case sendMessage(GameClientMessage)
	case showLoaf(LoafState)

	case failedToJoinMatch
	case failedToReconnect
	case exitSilently
	case exitMatch
}

enum OnlineRoomCancellable: Int, Identifiable {
	case gameClient

	var id: Int {
		rawValue
	}
}

class OnlineRoomViewModel: ExtendedViewModel<OnlineRoomViewAction, OnlineRoomCancellable>, ObservableObject {
	@Published var match: Loadable<Match> = .notLoaded {
		didSet {
			matchOptions = match.value?.optionSet ?? Set()
			gameOptions = match.value?.gameOptionSet ?? Set()

			if let match = match.value {
				openClientConnection(to: match)
			}
		}
	}

	let initialMatchId: Match.ID?
	private var userId: User.ID!

	@Published private(set) var matchOptions: Set<Match.Option> = Set()
	@Published private(set) var gameOptions: Set<GameState.Option> = Set()
	@Published private(set) var readyPlayers: Set<UUID> = Set()

	@Published var exiting = false

	@Published var clientConnected = false
	@Published var reconnectAttempts = 0
	@Published var reconnecting = false

	private let actions = PassthroughSubject<OnlineRoomAction, Never>()
	var actionsPublisher: AnyPublisher<OnlineRoomAction, Never> {
		actions.eraseToAnyPublisher()
	}

	private let creatingNewMatch: Bool

	init(matchId: Match.ID?, creatingNewMatch: Bool, match: Loadable<Match>) {
		self.initialMatchId = matchId
		self.creatingNewMatch = creatingNewMatch
		self._match = .init(initialValue: match)
	}

	override func postViewAction(_ viewAction: OnlineRoomViewAction) {
		switch viewAction {
		case .onAppear(let id):
			userId = id
			initialize()
		case .retryInitialAction:
			initialize()
		case .refresh:
			actions.send(.loadMatchDetails)
		case .toggleReadiness:
			toggleReadiness()
		case .subscribedToClient(let publisher):
			subscribedToClient(publisher)

		case .requestExit:
			exiting = true
		case .exitMatch:
			exiting = false
			actions.send(.exitMatch)
		case .dismissExit:
			exiting = false
		}
	}

	private func initialize() {
		if creatingNewMatch {
			actions.send(.createNewMatch)
		} else {
			actions.send(.joinMatch)
		}
	}

	var userIsHost: Bool {
		userId == match.value?.host?.id
	}

	var player: Player {
		if matchOptions.contains(.hostIsWhite) {
			return userIsHost ? .white : .black
		} else {
			return userIsHost ? .black : .white
		}
	}

	private func toggleReadiness() {
		guard let id = userIsHost ? match.value?.host?.id : match.value?.opponent?.id else {
			return
		}

		if isPlayerReady(id: id) {
			readyPlayers.remove(id)
		} else {
			readyPlayers.insert(id)
		}
		actions.send(.sendMessage(.readyToPlay))
	}

	private func toggleGameOption(_ option: GameState.Option) {
		let enabled = gameOptions.contains(option)
		gameOptions.set(option, to: !enabled)
		actions.send(.sendMessage(.setOption(.gameOption(option), !enabled)))
	}

	func isPlayerReady(id: UUID?) -> Bool {
		guard let id = id else { return false }
		return readyPlayers.contains(id)
	}

	func optionEnabled(option: Match.Option) -> Binding<Bool> {
		Binding(
			get: { [weak self] in self?.matchOptions.contains(option) ?? false },
			set: { [weak self] newValue in
				guard let self = self, self.userIsHost else { return }
				self.matchOptions.set(option, to: newValue)
				self.actions.send(.sendMessage(.setOption(.customOption(option.rawValue), newValue)))
			}
		)
	}

	func gameOptionEnabled(option: GameState.Option) -> Binding<Bool> {
		Binding(
			get: { [weak self] in self?.gameOptions.contains(option) ?? false },
			set: { [weak self] newValue in
				guard let self = self, self.userIsHost else { return }
				self.gameOptions.set(option, to: newValue)
				self.actions.send(.sendMessage(.setOption(.gameOption(option), newValue)))
			}
		)
	}

	private func playerJoined(id: UUID) {
		if userIsHost {
			actions.send(.showLoaf(LoafState("An opponent has joined!", style: .success())))
		}
		actions.send(.loadMatchDetails)
	}

	private func playerLeft(id: UUID) {
		readyPlayers.remove(id)
		if userIsHost && id == match.value?.opponent?.id {
			actions.send(.showLoaf(LoafState("Your opponent has left!", style: .warning())))
			actions.send(.loadMatchDetails)
		} else if !userIsHost && id == match.value?.host?.id {
			actions.send(.showLoaf(LoafState("The host has left!", style: .warning())))
			actions.send(.closeConnection)
		}
	}

	private func updateGameState(to state: GameState) {
		// Unsubscribe from future events so we don't disrupt the game
		cancel(withId: .gameClient)

		actions.send(.startGame(state, player))
	}

	private func setOption(_ option: GameServerMessage.Option, to value: Bool) {
		switch option {
		case .gameOption(let option): gameOptions.set(option, to: value)
		case .customOption(let string):
			if let matchOption = Match.Option(rawValue: string) {
				matchOptions.set(matchOption, to: value)
			}
		}
	}
}

// MARK: - GameClient

extension OnlineRoomViewModel {
	private func openClientConnection(to match: Match) {
		if let url = match.webSocketPlayingUrl {
			openClientConnection(to: url)
		} else {
			actions.send(.failedToJoinMatch)
		}
	}

	private func reopenClientConnection() {
		openClientConnection(to: nil)
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
					self.clientConnected = false
				}, receiveValue: {
					self.handleGameClientEvent($0)
				}
			)
			.store(in: self, withId: .gameClient)
	}

	private func handleGameClientError(_ error: GameClientError) {
		guard reconnectAttempts < OnlineGameClient.maxReconnectAttempts else {
			actions.send(.failedToReconnect)
			return
		}

		self.reconnectAttempts += 1
		self.reconnecting = true
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			self.reopenClientConnection()
		}
	}

	private func handleGameClientEvent(_ event: GameClientEvent) {
		switch event {
		case .connected, .alreadyConnected:
			clientConnected = true
			reconnecting = false
			reconnectAttempts = 0
		case .message(let message):
			handleGameClientMessage(message)
		}
	}

	private func handleGameClientMessage(_ message: GameServerMessage) {
		switch message {
		case .playerJoined(let id):
			playerJoined(id: id)
		case .playerLeft(let id):
			playerLeft(id: id)
		case .gameState(let state):
			updateGameState(to: state)
		case .playerReady(let id, let ready):
			readyPlayers.set(id, to: ready)
		case .setOption(let option, let value):
			setOption(option, to: value)
		case .error(let error):
			actions.send(.showLoaf(error.loaf))
		case .forfeit, .gameOver, .message, .spectatorLeft, .spectatorJoined:
			logger.error("Received invalid message in Match Details: \(message)")
		}
	}
}

// MARK: - Strings

extension OnlineRoomViewModel {
	var title: String {
		if let host = match.value?.host?.displayName {
			return "\(host)'s match"
		} else {
			return "Match Details"
		}
	}

	var startButtonText: String {
		guard let hostId = match.value?.host?.id,
			let opponentId = match.value?.opponent?.id else {
			return ""
		}

		let user = userIsHost ? hostId : opponentId
		let opponent = userIsHost ? opponentId : hostId

		if readyPlayers.contains(user) {
			return "Cancel"
		} else {
			return readyPlayers.contains(opponent) ? "Start" : "Ready"
		}
	}

	var reconnectingMessage: String {
		"Reconnecting (\(reconnectAttempts)/\(OnlineGameClient.maxReconnectAttempts))..."
	}

	func errorMessage(from error: Error) -> String {
		guard let matchError = error as? MatchRepositoryError else {
			return error.localizedDescription
		}

		switch matchError {
		case .usingOfflineAccount: return "You're offline"
		case .apiError(let apiError): return apiError.errorDescription ?? apiError.localizedDescription
		}
	}
}

extension GameServerError {
	var loaf: LoafState {
		return LoafState("\(description) (\(code))", style: .error())
	}
}
