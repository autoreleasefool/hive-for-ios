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
import NIOWebSocket

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

	private var account: Account!

	private(set) var matchId: Match.ID?
	private var creatingNewMatch: Bool = false

	private(set) lazy var client: HiveGameClient = {
		let client = HiveGameClient()
		client.delegate = self
		return client
	}()

	var userIsHost: Bool {
		account.userId == match?.host?.id
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
					self?.handle(newMatch: match)
				}
			)
			.store(in: self)
	}

	private func handle(newMatch: CreateMatchResponse) {
		self.handle(match: newMatch.details)
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
		match = nil
	}

	private func handle(match: Match) {
		self.matchId = match.id
		self.match = match
		self.gameOptions = match.gameOptions
		client.webSocketURL = match.webSocketURL
		errorLoaf = nil

		client.openConnection()
		LoadingHUD.shared.show()
	}

	func isPlayerReady(id: UUID?) -> Bool {
		guard let id = id else { return false }
		return readyPlayers.contains(id)
	}

	func optionEnabled(option: GameState.Option) -> Binding<Bool> {
		Binding(
			get: { self.gameOptions.contains(option) },
			set: {
				guard self.userIsHost else { return }
				if $0 {
					self.gameOptions.insert(option)
				} else {
					self.gameOptions.remove(option)
				}
				self.client.send(.setOption(option, $0))
			}
		)
	}

	func setAccount(to account: Account) {
		self.account = account
	}

	private func playerJoined(id: UUID) {
		fetchMatchDetails()
	}

	private func playerLeft(id: UUID) {
		readyPlayers.remove(id)
		if userIsHost {
			fetchMatchDetails()
		} else {
			match = nil
		}
	}
}

// MARK: - HiveGameClientDelegate

extension MatchDetailViewModel: HiveGameClientDelegate {
	func clientDidConnect(_ hiveGameClient: HiveGameClient) {
		LoadingHUD.shared.hide()
	}

	func clientDidDisconnect(_ hiveGameClient: HiveGameClient, code: WebSocketErrorCode?) {
		#warning("TODO: handle abnormal disconnects")
	}

	func clientDidReceiveMessage(_ hiveGameClient: HiveGameClient, message: GameServerMessage) {
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
			print(#"Received message "\#(string)" from \#(id)"#)
		case .error(let error):
			errorLoaf = error.loaf.build()
		case .forfeit:
			print("Received invalid forfeit message in Match Details")
		}
	}
}
