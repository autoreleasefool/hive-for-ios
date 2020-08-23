//
//  Match.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine

typealias CreateMatchResponse = Match
typealias JoinMatchResponse = Match

struct Match: Identifiable, Decodable, Equatable {
	let id: UUID

	let host: User?
	let opponent: User?
	let winner: User?
	let moves: [Move]

	let options: String
	let gameOptions: String
	let createdAt: Date?
	let duration: TimeInterval?
	let status: Status
	let isComplete: Bool

	var webSocketPlayingUrl: URL? {
		guard let host = HiveAPI.baseURL.host else { return nil }
		return URL(string: "wss://\(host)/\(id)/play")
	}

	var webSocketSpectatingUrl: URL? {
		guard let host = HiveAPI.baseURL.host else { return nil }
		return URL(string: "wss://\(host)/\(id)/spectate")
	}

	static func createOfflineMatch(against enemy: AgentConfiguration) -> Match {
		Match(
			id: UUID(),
			host: User.createOfflineUser(),
			opponent: enemy.user,
			winner: nil,
			moves: [],
			options: OptionSet.encode(Option.defaultOfflineSet),
			gameOptions: OptionSet.encode(GameState().options),
			createdAt: Date(),
			duration: nil,
			status: .notStarted,
			isComplete: false
		)
	}
}

// MARK: - User

extension Match {
	struct User: Identifiable, Decodable, Equatable {
		let id: UUID
		let displayName: String
		let elo: Int
		let avatarUrl: String?

		var isComputer: Bool {
			AgentConfiguration.exists(withId: id)
		}

		var isOffline: Bool {
			id == Account.offline.userId
		}

		static func createOfflineUser() -> User {
			User(
				id: Account.offline.userId,
				displayName: "Local",
				elo: 0,
				avatarUrl: nil
			)
		}
	}
}

// MARK: - Option

extension Match {
	enum Option: String, CaseIterable {
		static var defaultOfflineSet: Set<Option> {
			[.hostIsWhite]
		}

		case hostIsWhite = "HostIsWhite"
		case asyncPlay = "AsyncPlay"

		var enabled: Bool {
			switch self {
			case .hostIsWhite: return true
			case .asyncPlay: return false
			}
		}

		static var enabledOptions: [Option] {
			allCases.filter { $0.enabled }
		}
	}
}

// MARK: - Status

extension Match {
	enum Status: Int, Decodable {
		case notStarted = 1
		case active = 2
		case ended = 3
	}
}

// MARK: - Move

extension Match {
	struct Move: Identifiable, Decodable, Equatable {
		let id: UUID
		let notation: String
		let ordinal: Int
		let date: Date
	}
}

// MARK: - Formatting

extension Match {
	var optionSet: Set<Match.Option> {
		OptionSet.parse(options)
	}

	var gameOptionSet: Set<GameState.Option> {
		OptionSet.parse(gameOptions)
	}
}

extension Match.User {
	var avatarURL: URL? {
		guard let url = avatarUrl else { return nil }
		return URL(string: url)
	}
}

#if DEBUG

extension Match {
	static var matches: [Match] {
		[
			Match(
				id: UUID(),
				host: Match.User.users[0],
				opponent: Match.User.users[1],
				winner: nil,
				moves: [Move(id: UUID(), notation: "wQ", ordinal: 0, date: Date())],
				options: "HostIsWhite:true",
				gameOptions: "Mosquito:true;LadyBug:true;PillBug:true",
				createdAt: Date(),
				duration: nil,
				status: .active,
				isComplete: false
			),
			Match(
				id: UUID(),
				host: Match.User.users[0],
				opponent: Match.User.users[2],
				winner: nil,
				moves: [],
				options: "HostIsWhite:true",
				gameOptions: "Mosquito:true",
				createdAt: Date(),
				duration: nil,
				status: .notStarted,
				isComplete: false
			),
		]
	}
}

extension Match.User {
	static var users: [Match.User] {
		[
			Match.User(
				id: UUID(),
				displayName: "Joseph",
				elo: 1000,
				avatarUrl: "https://avatars1.githubusercontent.com/u/6619581?v=4"
			),
			Match.User(
				id: UUID(),
				displayName: "Scott",
				elo: 893,
				avatarUrl: "https://avatars3.githubusercontent.com/u/5544925?v=4"
			),
			Match.User(
				id: UUID(),
				displayName: "Dann Beauregard",
				elo: 3129,
				avatarUrl: "https://avatars2.githubusercontent.com/u/30088157?v=4"
			),
		]
	}
}

#endif
