//
//  ContentViewViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import AuthenticationServices
import Foundation
import Combine
import SwiftUI

enum ContentViewViewAction: BaseViewAction {
	case onAppear
	case playOffline
	case playAsGuest
	case accountChanged
	case handleSignInWithApple(Result<ASAuthorization, Error>)
}

enum ContentViewAction: BaseAction {
	case loadAccount
	case loadOfflineAccount
	case createGuestAccount
	case signInWithApple(User.SignInWithApple.Request)
	case loggedOut
	case appVersionUnsupported
	case accountNeedsInformation
	case showLoaf(LoafState)
}

class ContentViewViewModel: ViewModel<ContentViewViewAction>, ObservableObject {
	@Published var account: Loadable<AnyAccount> = .notLoaded {
		didSet {
			guard account != oldValue, let error = account.error else { return }
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
				actions.send(.showLoaf(LoafState(errorMessage, style: .error())))
			}
		}
	}

	@Published var isPresentingUnsupportedVersionSheet: Bool = false
	@Published var guestName: GuestNameAlert?

	init(account: Loadable<AnyAccount> = .notLoaded) {
		_account = .init(initialValue: account)
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
		case .handleSignInWithApple(let result):
			handleSignInWithApple(result)
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
			.publisher(for: NSNotification.Name.Account.Created)
			.receive(on: RunLoop.main)
			.sink { [weak self] notification in
				guard let user = notification.object as? User else {
					return
				}
				self?.handleAccountUser(user)
			}
			.store(in: self)

		NotificationCenter.default
			.publisher(for: NSNotification.Name.Account.Loaded)
			.receive(on: RunLoop.main)
			.sink { [weak self] notification in
				guard let user = notification.object as? User else {
					return
				}
				self?.handleAccountUser(user)
			}
			.store(in: self)
	}

	private func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
		guard case .success(let authorization) = result else {
			actions.send(.showLoaf(LoafState("Sign in with Apple failed", style: .error())))
			return
		}

		guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
					let identityToken = appleIDCredential.identityToken,
					let identityTokenString = String(data: identityToken, encoding: .utf8) else {
			actions.send(.showLoaf(LoafState("Invalid credentials", style: .error())))
			return
		}

		actions.send(
			.signInWithApple(
				User.SignInWithApple.Request(
					appleIdentityToken: identityTokenString,
					displayName: nil,
					avatarUrl: nil
				)
			)
		)
	}

	private func handleAccountUser(_ user: User) {
		if user.isGuest {
			self.guestName = GuestNameAlert(guestName: user.displayName)
		}

		if user.displayName == User.anonymousUserDisplayName {
			self.actions.send(.accountNeedsInformation)
		}
	}
}

extension ContentViewViewModel {
	struct GuestNameAlert: Identifiable {
		var id: String { guestName }
		let guestName: String
	}
}
