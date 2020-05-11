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
	struct User: Identifiable, Decodable, Equatable {
		let id: UUID
		let displayName: String
		let elo: Double
		let avatarUrl: String?
	}

	enum Status: Int, Decodable {
		case notStarted = 1
		case active = 2
		case ended = 3
	}

	struct Move: Identifiable, Decodable, Equatable {
		let id: UUID
		let notation: String
		let ordinal: Int
		let date: Date
	}

	enum Option: String, CaseIterable {
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

	let id: UUID

	let host: User?
	let opponent: User?
	let winner: User?
	let moves: [Move]

	let hostElo: Double?
	let opponentElo: Double?

	let options: String
	let gameOptions: String
	let createdAt: Date?
	let duration: TimeInterval?
	let status: Status
	let isComplete: Bool

	var webSocketURL: URL? {
		guard let host = HiveAPI.baseURL.host else { return nil }
		return URL(string: "wss://\(host)/\(id)/play")
	}
}

// MARK: Formatting

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

	var formattedELO: String {
		String(format: "%.0f", elo)
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
				hostElo: 1000.0,
				opponentElo: 1200.0,
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
				hostElo: 10300.0,
				opponentElo: 100.0,
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
