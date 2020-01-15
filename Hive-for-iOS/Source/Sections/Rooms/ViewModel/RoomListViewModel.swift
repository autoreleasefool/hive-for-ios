//
//  RoomListViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import Combine

class RoomListViewModel: ObservableObject {
	@Published var rooms: [Room] = []
	@Published var runningTask: AnyCancellable?
	@Published var error: HiveAPIError?

	func fetchRooms() {
		guard runningTask == nil else { return }
		runningTask = HiveAPI
			.shared
			.rooms()
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					self?.runningTask = nil
					if case let .failure(error) = result {
						self?.error = error
					}
				},
				receiveValue: { [weak self] rooms in
					self?.runningTask = nil
					self?.rooms = rooms
				}
			)
	}
}
