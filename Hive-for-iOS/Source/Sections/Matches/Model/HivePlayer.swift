//
//  HivePlayer.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

struct HivePlayer: Identifiable, Codable {
	let id: Int
	let name: String
	let elo: Double
	let avatar: String

	var avatarUrl: URL? {
		return URL(string: avatar)
	}

	var formattedELO: String {
		return String(format: "%.0f", elo)
	}

	static let players: [HivePlayer] = [
		HivePlayer(id: 0, name: "Joseph", elo: 4324.98022, avatar: "https://avatars1.githubusercontent.com/u/6619581?v=4"),
		HivePlayer(id: 1, name: "Jordan", elo: 798, avatar: "https://avatars1.githubusercontent.com/u/6619581?v=4"),
		HivePlayer(id: 2, name: "Audriana", elo: 10.02382, avatar: "https://avatars1.githubusercontent.com/u/6619581?v=4"),
		HivePlayer(id: 3, name: "Pamela", elo: 100.432, avatar: "https://avatars1.githubusercontent.com/u/6619581?v=4"),
		HivePlayer(id: 4, name: "Ruben", elo: 101, avatar: "https://avatars1.githubusercontent.com/u/6619581?v=4"),
	]
}
