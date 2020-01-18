//
//  RoomDetailViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import Combine
import Loaf
import HiveEngine

enum RoomDetailTask: Identifiable {
	case refreshRoomDetails
	case toggleOption(GameState.Options)

	var id: String {
		switch self {
		case .refreshRoomDetails: return "refreshRoomDetails"
		case .toggleOption(let option): return "toggleOption.\(option)"
		}
	}
}

enum RoomDetailViewAction: BaseViewAction {
	case onAppear
	case onDisappear
	case refreshRoomDetails
}

class RoomDetailViewModel: ViewModel<RoomDetailViewAction, RoomDetailTask>, ObservableObject {
	@Published private(set) var room: Room?
	@Published private(set) var options: Set<GameState.Options> = []
	@Published var errorLoaf: Loaf?

	private let roomId: String

	init(roomId: String) {
		self.roomId = roomId
	}

	override func postViewAction(_ viewAction: RoomDetailViewAction) {
		switch viewAction {
		case .onAppear, .refreshRoomDetails: fetchRoomDetails()
		case .onDisappear: cleanUp()
		}
	}

	private func cleanUp() {
		errorLoaf = nil
		cancelAllRequests()
	}

	private func fetchRoomDetails() {
		let request = HiveAPI
			.shared
			.room(id: roomId)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					self?.completeCancellable(withId: .refreshRoomDetails)
					if case let .failure(error) = result {
						self?.errorLoaf = error.loaf
					}
				},
				receiveValue: { [weak self] room in
					self?.errorLoaf = nil
					self?.room = room
				}
			)
		register(cancellable: request, withId: .refreshRoomDetails)
	}
}
