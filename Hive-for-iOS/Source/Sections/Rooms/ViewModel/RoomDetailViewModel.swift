//
//  RoomDetailViewModel.swift
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

enum RoomDetailTask: Identifiable {
	case refreshRoomDetails
	case modifyOptions

	var id: String {
		switch self {
		case .refreshRoomDetails: return "refreshRoomDetails"
		case .modifyOptions: return "modifyOptions"
		}
	}
}

enum RoomDetailViewAction: BaseViewAction {
	case onAppear
	case onDisappear
	case refreshRoomDetails
	case modifyOptions
}

class RoomDetailViewModel: ViewModel<RoomDetailViewAction, RoomDetailTask>, ObservableObject {
	@Published private(set) var room: Room?
	@Published private(set) var options: GameOptionData = GameOptionData(options: [])
	@Published var errorLoaf: Loaf?

	let roomId: String

	init(roomId: String) {
		self.roomId = roomId
	}

	override func postViewAction(_ viewAction: RoomDetailViewAction) {
		switch viewAction {
		case .onAppear, .refreshRoomDetails: fetchRoomDetails()
		case .onDisappear: cleanUp()
		case .modifyOptions: break
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
					self?.options.update(with: room.options)
				}
			)
		register(cancellable: request, withId: .refreshRoomDetails)
	}
}

final class GameOptionData: ObservableObject {
	private(set) var options: Set<GameState.Options>

	init(options: Set<GameState.Options>) {
		self.options = options
	}

	func update(with: Set<GameState.Options>) {
		self.options = with
	}

	func binding(for option: GameState.Options) -> Binding<Bool> {
		return Binding(get: {
			return self.options.contains(option)
		}, set: {
			if $0 {
				self.options.insert(option)
			} else {
				self.options.remove(option)
			}
		})
	}
}
