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
	case appVersionUnsupported
	case showLoaf(LoafState)
}

class ContentViewViewModel: ViewModel<ContentViewViewAction>, ObservableObject {
	@Published var guestAccount: Loadable<Account> = .notLoaded {
		didSet {
			guard guestAccount != oldValue,
						let error = guestAccount.error else { return }
			let errorMessage: String?
			if let accountError = error as? AccountRepositoryError {
				switch accountError {
				case .notFound, .keychainError, .loggedOut:
					errorMessage = "Unknown error"
				case .apiError(let error):
					if case .unsupported = error {
						// Avoid toast when unsupported, since we'll show an overlay
						errorMessage = nil
					} else {
						errorMessage = error.localizedDescription
					}
				}
			} else {
				errorMessage = error.localizedDescription
			}

			if let errorMessage = errorMessage {
				actions.send(.showLoaf(LoafState(errorMessage, state: .error)))
			}
		}
	}

	@Published var isPresentingUnsupportedVersionSheet: Bool = false
	@Published var guestName: GuestNameAlert?

	init(guestAccount: Loadable<Account> = .notLoaded) {
		_guestAccount = .init(initialValue: guestAccount)
		super.init()

		subscribeToUpdates()
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

	private func subscribeToUpdates() {
		NotificationCenter.default
			.publisher(for: NSNotification.Name.Account.Unauthorized)
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in self?.actions.send(.loggedOut) }
			.store(in: self)

		NotificationCenter.default
			.publisher(for: NSNotification.Name.AppInfo.Unsupported)
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in self?.actions.send(.appVersionUnsupported) }
			.store(in: self)

		NotificationCenter.default
			.publisher(for: NSNotification.Name.Account.SignupSuccess)
			.receive(on: RunLoop.main)
			.sink { [weak self] notification in
				guard let successResponse = notification.object as? User.Signup.Success,
					successResponse.isGuest else {
					return
				}
				self?.guestName = GuestNameAlert(guestName: successResponse.response.displayName)
			}
			.store(in: self)
	}
}

extension ContentViewViewModel {
	struct GuestNameAlert: Identifiable {
		var id: String { guestName }
		let guestName: String
	}
}
