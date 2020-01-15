//
//  Room.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine

struct Room: Identifiable, Codable {
	let id: String
	let host: Player
	let opponent: Player?
	let viewers: [Player]
	let options: Set<GameState.Options>

	static let rooms: [Room] = [
		Room(
			id: "0",
			host: Player.players[0],
			opponent: nil,
			viewers: Array(Player.players.dropFirst()),
			options: [.mosquito]
		),
		Room(
			id: "1",
			host: Player.players[1],
			opponent: Player.players[2],
			viewers: Array(Player.players.dropFirst(3)),
			options: [.mosquito, .ladyBug, .pillBug]
		),
	]
}
