//
//  MatchDetailViewModelV2.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI
import HiveEngine

enum MatchDetailViewActionV2: BaseViewAction {
	case startMatch
	case exitMatch
}

enum MatchDetailAction: BaseAction {
	case leftMatch
	case loadMatch
	case presentLoaf(LoafState)
}

class MatchDetailViewModelV2: ViewModel<MatchDetailViewActionV2>, ObservableObject {
	private(set) var matchId: Match.ID?
	@Published var match: Loadable<Match>
	@Published var account: Loadable<AccountV2> = .notLoaded

	@Published var inGame: Bool = false
	@Published var exiting: Bool = false

	@Published private(set) var matchOptions: Set<Match.Option> = Set()
	@Published private(set) var gameOptions: Set<GameState.Option> = Set()
	@Published private(set) var readyPlayers: Set<UUID> = Set()

	private var client: HiveGameClient!

	private(set) var actions = PassthroughSubject<MatchDetailAction, Never>()

	init(id: Match.ID?, match: Loadable<Match> = .notLoaded) {
		self.matchId = id
		self._match = .init(initialValue: match)
		super.init()

		subscribeToPublishers()
	}

	var userIsHost: Bool {
		account.value?.userId == match.value?.host?.id
	}

	var isRefreshing: Binding<Bool> {
		Binding(
			get: { [weak self] in
				if case .loading = self?.match {
					return true
				}
				return false
			},
			set: { _ in }
		)
	}

	func isPlayerReady(id: UUID?) -> Bool {
		guard let id = id else { return false }
		return readyPlayers.contains(id)
	}

	func name(forOption option: Match.Option) -> String {
		switch option {
		case .asyncPlay: return "Asynchronous play"
		case .hostIsWhite: return "\(match.value?.host?.displayName ?? "Host") is white"
		}
	}

	func name(forOption option: GameState.Option) -> String {
		return option.preview ?? option.displayName
	}

	func optionEnabled(option: Match.Option) -> Binding<Bool> {
		Binding(
			get: { [weak self] in self?.matchOptions.contains(option) ?? false },
			set: { [weak self] in
				guard let self = self, self.userIsHost else { return }
				self.matchOptions.set(option, to: $0)
				self.client.send(.setOption(.matchOption(option), $0))
			}
		)
	}

	func gameOptionEnabled(option: GameState.Option) -> Binding<Bool> {
		Binding(
			get: { [weak self] in self?.gameOptions.contains(option) ?? false },
			set: { [weak self] in
				guard let self = self, self.userIsHost else { return }
				self.gameOptions.set(option, to: $0)
				self.client.send(.setOption(.gameOption(option), $0))
			}
		)
	}

	// MARK: - Actions

	private func subscribeToPublishers() {
		$account
			.receive(on: DispatchQueue.main)
			.sink { [weak self] in
				if let account = $0.value, self?.client == nil {
					self?.client = HiveGameClient(account: account)
				}
			}
			.store(in: self)

		$match
			.receive(on: DispatchQueue.main)
			.sink { [weak self] in
				if let match = $0.value {
					self?.handleMatch(match)
				}
			}
			.store(in: self)
	}

	override func postViewAction(_ viewAction: MatchDetailViewActionV2) {
		switch viewAction {
		case .startMatch:
			toggleReadiness()
		case .exitMatch:
			exitMatch()
		}
	}

	private func toggleReadiness() {
		guard let id = userIsHost ? match.value?.host?.id : match.value?.opponent?.id else { return }
		if isPlayerReady(id: id) {
			readyPlayers.remove(id)
			client.send(.readyToPlay)
		} else {
			readyPlayers.insert(id)
			client.send(.readyToPlay)
		}
	}

	private func playerJoined(id: UUID) {
		if userIsHost {
			actions.send(.presentLoaf(LoafState("An opponent has joined!", state: .success)))
		}
		actions.send(.loadMatch)
	}

	private func playerLeft(id: UUID) {
		readyPlayers.remove(id)
		if userIsHost && id == match.value?.opponent?.id {
			actions.send(.presentLoaf(LoafState("Your opponent has left!", state: .warning)))
			actions.send(.loadMatch)
		} else if !userIsHost && id == match.value?.host?.id {
			actions.send(.presentLoaf(LoafState("The host has left!", state: .warning)))
			client.close()
			actions.send(.leftMatch)
		}
	}

	private func updateGameState(to state: GameState) {
		let player: Player
		if userIsHost {
			player = matchOptions.contains(.hostIsWhite) ? .white : .black
		} else {
			player = matchOptions.contains(.hostIsWhite) ? .black : .white
		}

//		gameViewModel.setPlayer(to: player)
//		gameViewModel.gameStateStore.send(state)
//		beginGame.send()
	}

	private func setOption(_ option: GameServerMessage.Option, to value: Bool) {
		switch option {
		case .gameOption(let option): self.gameOptions.set(option, to: value)
		case .matchOption(let option): self.matchOptions.set(option, to: value)
		}
	}

	private func exitMatch() {
		client.send(.forfeit)
		client.close()
		actions.send(.leftMatch)
	}

	private func handleMatch(_ match: Match) {
		matchId = match.id
		matchOptions = match.optionSet
		gameOptions = match.gameOptionSet

		if !client.isConnected {
			if let url = match.webSocketURL {
				openClientConnection(to: url)
			} else {
				actions.send(.presentLoaf(LoafState("Failed to join match", state: .error)))
				actions.send(.leftMatch)
			}
		}
	}
}

// MARK: - Client

extension MatchDetailViewModelV2 {
	private func openClientConnection(to url: URL) {
		client.url = url
		LoadingHUD.shared.show()

		client.openConnection()
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						self?.handleGameClientError(error)
					}
				},
				receiveValue: { [weak self] event in
					self?.handleGameClientEvent(event)
				}
			).store(in: self)
	}

	private func handleGameClientError(_ error: GameClientError) {
		LoadingHUD.shared.hide()
		actions.send(.leftMatch)
		#warning("TODO: add a reconnect mechanism")
		print("Client disconnected: \(error)")
	}

	private func handleGameClientEvent(_ event: GameClientEvent) {
		switch event {
		case .connected:
			LoadingHUD.shared.hide()
		case .closed:
			actions.send(.leftMatch)
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
		case .message(let id, let string):
			#warning("TODO: display message")
			print("Received message '\(string)' from \(id)")
		case .error(let error):
			actions.send(.presentLoaf(error.loaf))
		case .forfeit, .gameOver:
			print("Received invalid message in Match Details: \(message)")
		}
	}
}

// MARK: - Strings

extension MatchDetailViewModelV2 {
	var title: String {
		if let host = match.value?.host?.displayName {
			return "\(host)'s match"
		} else {
			return "Match Details"
		}
	}

	var startButtonText: String {
		guard let hostId = match.value?.host?.id, let opponentId = match.value?.opponent?.id else { return "" }

		let user = userIsHost ? hostId : opponentId
		let opponent = userIsHost ? opponentId : hostId

		if readyPlayers.contains(user) {
			return "Cancel"
		} else {
			return readyPlayers.contains(opponent) ? "Start" : "Ready"
		}
	}
}

private extension GameState.Option {
	var preview: String? {
		switch self {
		case .mosquito: return "M"
		case .ladyBug: return "L"
		case .pillBug: return "P"
		default: return nil
		}
	}
}
