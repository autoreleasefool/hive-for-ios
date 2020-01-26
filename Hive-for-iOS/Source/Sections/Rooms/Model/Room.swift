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
	let host: HivePlayer
	let opponent: HivePlayer?
	let viewers: [HivePlayer]
	let options: Set<GameState.Options>

	static let rooms: [Room] = [
		Room(
			id: "0",
			host: HivePlayer.players[0],
			opponent: nil,
			viewers: Array(HivePlayer.players.dropFirst()),
			options: [.mosquito]
		),
		Room(
			id: "1",
			host: HivePlayer.players[1],
			opponent: HivePlayer.players[2],
			viewers: Array(HivePlayer.players.dropFirst(3)),
			options: [.mosquito, .ladyBug, .pillBug]
		),
	]
}
