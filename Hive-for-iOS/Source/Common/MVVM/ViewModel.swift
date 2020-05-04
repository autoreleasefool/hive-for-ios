//
//  ViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-17.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine

protocol BaseViewAction { }

protocol BaseAction { }

class ViewModel<ViewAction> where ViewAction: BaseViewAction {

	private var cancellables: [AnyCancellable] = []

	func postViewAction(_ viewAction: ViewAction) {
		fatalError("Classes extending ViewModel must override postViewAction(_:)")
	}

	func cancelAllRequests() {
		cancellables.removeAll()
	}

	fileprivate func store(_ cancellable: AnyCancellable) {
		cancellable.store(in: &cancellables)
	}
}

extension AnyCancellable {
	func store<V>(in model: ViewModel<V>) {
		model.store(self)
	}
}
