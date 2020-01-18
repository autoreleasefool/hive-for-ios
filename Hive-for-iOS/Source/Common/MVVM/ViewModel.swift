//
//  ViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-17.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine

protocol BaseViewAction { }

class ViewModel<ViewAction, CancellableID> where ViewAction: BaseViewAction, CancellableID: Identifiable {

	private var cancellables: [CancellableID.ID: AnyCancellable] = [:]

	func postViewAction(_ viewAction: ViewAction) {
		fatalError("Classes extending ViewModel must override postViewAction(_:)")
	}

	func register(cancellable: AnyCancellable, withId id: CancellableID) {
		if let existing = cancellables[id.id] {
			existing.cancel()
		}

		cancellables[id.id] = cancellable
	}

	func completeCancellable(withId id: CancellableID) {
		cancellables[id.id]?.cancel()
		cancellables[id.id] = nil
	}

	func cancelAllRequests() {
		for id in cancellables.keys {
			cancellables[id]?.cancel()
			cancellables[id] = nil
		}
	}
}
