//
//  RoomListViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Loaf

enum RoomListViewAction: BaseViewAction {
	case onAppear
	case onDisappear
	case refreshRooms
}

class RoomListViewModel: ViewModel<RoomListViewAction>, ObservableObject {
	@Published var errorLoaf: Loaf?

	@Published private(set) var rooms: [Room] = [] {
		willSet {
			#warning("TODO: should remove view models for rooms that no longer exist")
			newValue.forEach {
				guard self.roomViewModels[$0.id] == nil else { return }
				self.roomViewModels[$0.id] = RoomDetailViewModel(roomId: $0.id)
			}
		}
	}

	private(set) var roomViewModels: [String: RoomDetailViewModel] = [:]

	override func postViewAction(_ viewAction: RoomListViewAction) {
		switch viewAction {
		case .onAppear, .refreshRooms: refreshRooms()
		case .onDisappear: cleanUp()
		}
	}

	private func cleanUp() {
		errorLoaf = nil
		cancelAllRequests()
	}

	private func refreshRooms() {
		HiveAPI
			.shared
			.rooms()
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						self?.errorLoaf = error.loaf
					}
				},
				receiveValue: { [weak self] rooms in
					self?.errorLoaf = nil
					self?.rooms = rooms
				}
			)
			.store(in: self)
	}
}
