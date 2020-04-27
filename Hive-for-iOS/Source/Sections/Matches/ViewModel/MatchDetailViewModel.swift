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
	case startGame
	case exitGame
}

class MatchDetailViewModel: ViewModel<MatchDetailViewAction>, ObservableObject {
	@Published private(set) var match: Match?
	@Published private(set) var matchOptions: Set<Match.Option> = Set()
	@Published private(set) var gameOptions: Set<GameState.Option> = Set()
	@Published private(set) var readyPlayers: Set<UUID> = Set()

	private(set) var refreshComplete = PassthroughSubject<Void, Never>()
	private(set) var breadBox = PassthroughSubject<LoafState, Never>()
	private(set) var beginGame = PassthroughSubject<Void, Never>()

	private var api: HiveAPI?
	private var account: Account?
	private var client: HiveGameClient!
	private(set) var gameViewModel = HiveGameViewModel()

	private(set) var matchId: Match.ID?

	private(set) var leavingMatch = PassthroughSubject<Void, Never>()

	var userIsHost: Bool {
		account?.userId == match?.host?.id
	}

	var navigationBarTitle: String {
		if let host = match?.host {
			return "\(host.displayName)'s match"
		} else {
			return "New match"
		}
	}

	var startButtonText: String {
		guard let hostId = match?.host?.id, let opponentId = match?.opponent?.id else { return "" }

		let user = userIsHost ? hostId : opponentId
		let opponent = userIsHost ? opponentId : hostId

		if readyPlayers.contains(user) {
			return "Cancel"
		} else {
			return readyPlayers.contains(opponent) ? "Start" : "Ready"
		}
	}

	init(id: Match.ID?) {
		self.matchId = id
	}

	init(match: Match) {
		self.matchId = match.id
		self.match = match
		self.matchOptions = match.optionSet
		self.gameOptions = match.gameOptionSet
	}

	override func postViewAction(_ viewAction: MatchDetailViewAction) {
		switch viewAction {
		case .onAppear:
			if matchId == nil {
				createNewMatch()
			} else {
				joinMatch()
			}
		case .refreshMatchDetails:
			fetchMatchDetails()
		case .startGame:
			toggleReadiness()
		case .exitGame:
			exitGame()
		case .onDisappear:
			cancelAllRequests()
		}
	}

	private func fetchMatchDetails() {
		guard let matchId = matchId else {
			refreshComplete.send()
			return
		}

		api?.matchDetails(id: matchId)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					self?.refreshComplete.send()
					if case let .failure(error) = result {
						self?.breadBox.send(error.loaf)
					}
				},
				receiveValue: { [weak self] match in
					self?.handle(match: match)
				}
			)
			.store(in: self)
	}

	private func joinMatch() {
		guard let matchId = matchId else { return }

		api?.joinMatch(id: matchId)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						self?.breadBox.send(error.loaf)
						self?.resetAndLeave()
					}
				},
				receiveValue: { [weak self] joinedMatch in
					self?.handle(match: joinedMatch)

				}
			)
			.store(in: self)
	}

	private func createNewMatch() {
		api?.createMatch()
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						self?.breadBox.send(error.loaf)
						self?.resetAndLeave()
					}
				},
				receiveValue: { [weak self] match in
					self?.handle(match: match)
				}
			)
			.store(in: self)
	}

	private func toggleReadiness() {
		guard let id = userIsHost ? match?.host?.id : match?.opponent?.id else { return }
		if isPlayerReady(id: id) {
			readyPlayers.remove(id)
			client.send(.readyToPlay)
		} else {
			readyPlayers.insert(id)
			client.send(.readyToPlay)
		}
	}

	private func exitGame() {
		client.send(.forfeit)
		client.close()

		resetState()
		leavingMatch.send()
	}

	private func handle(match: Match) {
		self.matchId = match.id
		self.match = match
		self.matchOptions = match.optionSet
		self.gameOptions = match.gameOptionSet

		if !client.isConnected {
			if let url = match.webSocketURL {
				openConnection(to: url)
			} else {
				breadBox.send(LoafState("Failed to join match", state: .error))
				resetAndLeave()
			}
		}
	}

	private func resetAndLeave() {
		resetState()
		leavingMatch.send()
	}

	func isPlayerReady(id: UUID?) -> Bool {
		guard let id = id else { return false }
		return readyPlayers.contains(id)
	}

	func name(forOption option: Match.Option) -> String {
		switch option {
		case .asyncPlay: return "Asynchronous play"
		case .hostIsWhite: return "\(match?.host?.displayName ?? "Host") is white"
		}
	}

	func name(forOption option: GameState.Option) -> String {
		return option.displayName
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

	private func playerJoined(id: UUID) {
		if userIsHost {
			breadBox.send(LoafState("An opponent has joined!", state: .success))
		}
		fetchMatchDetails()
	}

	private func playerLeft(id: UUID) {
		readyPlayers.remove(id)
		if userIsHost && id == match?.opponent?.id {
			breadBox.send(LoafState("Your opponent has left!", state: .warning))
			fetchMatchDetails()
		} else if !userIsHost && id == match?.host?.id {
			breadBox.send(LoafState("The host has left!", state: .warning))
			resetState()
			client.close()
			leavingMatch.send()
		}
	}

	private func receivedGameState(_ state: GameState) {
		let player: Player
		if userIsHost {
			player = matchOptions.contains(.hostIsWhite) ? .white : .black
		} else {
			player = matchOptions.contains(.hostIsWhite) ? .black : .white
		}

		gameViewModel.setPlayer(to: player)
		gameViewModel.gameStateStore.send(state)
		beginGame.send()
	}

	private func setOption(_ option: GameServerMessage.Option, to value: Bool) {
		switch option {
		case .gameOption(let option): self.gameOptions.set(option, to: value)
		case .matchOption(let option): self.matchOptions.set(option, to: value)
		}
	}

	func setAccount(to account: Account) {
		self.account = account
		self.client = HiveGameClient(account: account)
		self.gameViewModel.setAccount(to: account)
		self.gameViewModel.setClient(to: client)
	}

	func setAPI(to api: HiveAPI) {
		self.api = api
	}

	func resetState() {
		if userIsHost {
			self.matchId = nil
		}

		self.match = nil
		self.gameViewModel.gameStateStore.send(nil)
		self.readyPlayers.removeAll()
	}
}

// MARK: - HiveGameClient

extension MatchDetailViewModel {
	private func openConnection(to url: URL) {
		client.url = url
		LoadingHUD.shared.show()

		client.openConnection()
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						self?.didReceive(error: error)
					}
				},
				receiveValue: { [weak self] event in
					self?.didReceive(event: event)
				}
			).store(in: self)
	}

	private func didReceive(error: GameClientError) {
		LoadingHUD.shared.hide()
		leavingMatch.send()
		#warning("TODO: add a reconnect mechanism")
		print("Client disconnected: \(error)")
	}

	private func didReceive(event: GameClientEvent) {
		switch event {
		case .connected:
			LoadingHUD.shared.hide()
		case .closed:
			leavingMatch.send()
		case .message(let message):
			didReceive(message: message)
		}
	}

	private func didReceive(message: GameServerMessage) {
		switch message {
		case .playerJoined(let id):
			playerJoined(id: id)
		case .playerLeft(let id):
			playerLeft(id: id)
		case .gameState(let state):
			receivedGameState(state)
		case .playerReady(let id, let ready):
			readyPlayers.set(id, to: ready)
		case .setOption(let option, let value):
			self.setOption(option, to: value)
		case .message(let id, let string):
			#warning("TODO: display message")
			print("Received message '\(string)' from \(id)")
		case .error(let error):
			breadBox.send(error.loaf)
		case .forfeit, .gameOver:
			print("Received invalid message in Match Details: \(message)")
		}
	}
}
