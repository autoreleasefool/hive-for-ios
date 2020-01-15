//
//  Room.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

struct RoomPreview: Identifiable, Codable {
	let id: String
	let host: Player
	let opponent: Player?
	let viewers: [Player]
}

struct Room: Codable {
	let id: String
	let preview: RoomPreview

	static let roomPreviews: [RoomPreview] = [
		RoomPreview(id: "0", host: Player.players[0], opponent: nil, viewers: Array(Player.players.dropFirst())),
		RoomPreview(id: "1", host: Player.players[1], opponent: Player.players[2], viewers: Array(Player.players.dropFirst(3))),
	]

	static let testRoom = Room(
		id: "0",
		preview: Room.roomPreviews[0]
	)
}
