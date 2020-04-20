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
	case startGame
	case exitGame
}

class MatchDetailViewModel: ViewModel<MatchDetailViewAction>, ObservableObject {
	@Published private(set) var match: Match?
	@Published private(set) var gameState: GameState?
	@Published private(set) var gameOptions: Set<GameState.Option> = Set()
	@Published private(set) var readyPlayers: Set<UUID> = Set()
	@Published var errorLoaf: Loaf?

	private var api: HiveAPI?
	private var account: Account?
	var client: HiveGameClient!

	private(set) var matchId: Match.ID?
	private var creatingNewMatch: Bool = false

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

	var showStartButton: Bool {
		match?.host != nil && match?.opponent != nil
	}

	var startButtonText: String {
		if let hostId = match?.host?.id, let opponentId = match?.opponent?.id {
			let user = userIsHost ? hostId : opponentId
			let opponent = userIsHost ? opponentId : hostId

			if readyPlayers.contains(user) {
				return "Not ready"
			} else if readyPlayers.contains(opponent) {
				return readyPlayers.contains(user) ? "Start" : "Ready"
			}
		}

		return ""
	}

	init(_ match: Match? = nil) {
		self.matchId = match?.id
		self.match = match

		super.init()

		if let match = match {
			self.gameOptions = match.gameOptions
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
		case .startGame:
			toggleReadiness()
		case .exitGame:
			exitGame()
		case .onDisappear:
			cleanUp()
		}
	}

	private func cleanUp() {
		errorLoaf = nil
		cancelAllRequests()
	}

	private func fetchMatchDetails() {
		guard let matchId = matchId else { return }

		api?.joinMatch(id: matchId)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						self?.errorLoaf = error.loaf
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
						self?.errorLoaf = error.loaf
					}
				},
				receiveValue: { [weak self] match in
					self?.handle(newMatch: match)
				}
			)
			.store(in: self)
	}

	private func handle(newMatch: CreateMatchResponse) {
		self.handle(match: newMatch)
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
		leavingMatch.send()
	}

	private func handle(match: Match) {
		self.matchId = match.id
		self.match = match
		self.gameOptions = match.gameOptions
		errorLoaf = nil

		if !client.isConnected {
			if let url = match.webSocketURL {
				openConnection(to: url)
			} else {
				errorLoaf = LoafState("Failed to join match", state: .error).build()
				leavingMatch.send()
			}
		}
	}

	func isPlayerReady(id: UUID?) -> Bool {
		guard let id = id else { return false }
		return readyPlayers.contains(id)
	}

	func optionEnabled(option: GameState.Option) -> Binding<Bool> {
		Binding(
			get: { [weak self] in self?.gameOptions.contains(option) ?? false },
			set: { [weak self] in
				guard let self = self, self.userIsHost else { return }
				if $0 {
					self.gameOptions.insert(option)
				} else {
					self.gameOptions.remove(option)
				}
				self.client.send(.setOption(option, $0))
			}
		)
	}

	private func playerJoined(id: UUID) {
		fetchMatchDetails()
	}

	private func playerLeft(id: UUID) {
		readyPlayers.remove(id)
		if userIsHost {
			fetchMatchDetails()
		} else {
			client.close()
			leavingMatch.send()
		}
	}

	func setAccount(to account: Account) {
		self.account = account
		self.client = HiveGameClient(account: account)
	}

	func setAPI(to api: HiveAPI) {
		self.api = api
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
			self.gameState = state
		case .playerReady(let id, let ready):
			if ready {
				readyPlayers.insert(id)
			} else {
				readyPlayers.remove(id)
			}
		case .setOption(let option, let value):
			if value {
				self.gameOptions.insert(option)
			} else {
				self.gameOptions.remove(option)
			}
		case .message(let id, let string):
			#warning("TODO: display message")
			print("Received message '\(string)' from \(id)")
		case .error(let error):
			errorLoaf = error.loaf.build()
		case .forfeit, .gameOver:
			print("Received invalid message in Match Details: \(message)")
		}
	}
}
