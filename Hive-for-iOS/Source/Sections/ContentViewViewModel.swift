//
//  ContentViewViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

enum ContentViewViewAction: BaseViewAction {
	case onAppear
	case playOffline
	case playAsGuest
	case accountChanged
}

enum ContentViewAction: BaseAction {
	case loadAccount
	case loadOfflineAccount
	case createGuestAccount
	case loggedOut
}

class ContentViewViewModel: ViewModel<ContentViewViewAction>, ObservableObject {
	override init() {
		super.init()
		subscribeToAccountUpdates()
	}

	private let actions = PassthroughSubject<ContentViewAction, Never>()
	var actionsPublisher: AnyPublisher<ContentViewAction, Never> {
		actions.eraseToAnyPublisher()
	}

	override func postViewAction(_ viewAction: ContentViewViewAction) {
		switch viewAction {
		case .onAppear:
			actions.send(.loadAccount)
		case .playOffline:
			actions.send(.loadOfflineAccount)
		case .playAsGuest:
			actions.send(.createGuestAccount)
		case .accountChanged:
			objectWillChange.send()
		}
	}

	private func subscribeToAccountUpdates() {
		NotificationCenter.default
			.publisher(for: NSNotification.Name.Account.Unauthorized)
			.map { _ in }
			.receive(on: RunLoop.main)
			.sink { [weak self] in self?.actions.send(.loggedOut) }
			.store(in: self)
	}
}
