//
//  RoomDetailViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import Combine
import HiveEngine

class RoomDetailViewModel: ObservableObject {
	@Published var room: Room?
	@Published var options: Set<GameState.Options> = []

	@Published var runningTask: AnyCancellable?
	@Published var error: HiveAPIError?

	private let roomId: String

	init(roomId: String) {
		self.roomId = roomId
	}

	func fetchRoomDetails() {
		guard runningTask == nil else { return }
		runningTask = HiveAPI
			.shared
			.room(id: roomId)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { result in
					if case let .failure(error) = result {
						self.error = error
					}
				},
				receiveValue: { [weak self] room in
					self?.room = room
				}
			)
	}
}
