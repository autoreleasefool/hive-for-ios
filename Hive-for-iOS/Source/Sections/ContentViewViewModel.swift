//
//  ContentViewViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import Combine

enum ContentViewViewAction: BaseViewAction {
	case loadAccount
}

enum ContentViewAction: BaseAction {
	case loadAccount
	case loggedOut
}

class ContentViewViewModel: ViewModel<ContentViewViewAction>, ObservableObject {
	@Published var account: Loadable<Account>
	@Published var routing = ContentView.Routing()

	init(account: Loadable<Account>) {
		self._account = .init(initialValue: account)
		super.init()

		subscribeToAccountUpdates()
	}

	private let actions = PassthroughSubject<ContentViewAction, Never>()
	var actionsPublisher: AnyPublisher<ContentViewAction, Never> {
		actions.eraseToAnyPublisher()
	}

	override func postViewAction(_ viewAction: ContentViewViewAction) {
		switch viewAction {
		case .loadAccount:
			actions.send(.loadAccount)
		}
	}

	private func subscribeToAccountUpdates() {
		NotificationCenter.default
			.publisher(for: NSNotification.Name.Account.Unauthorized)
			.map { _ in }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] in self?.actions.send(.loggedOut) }
			.store(in: self)
	}
}
