//
//  AccountInteractor.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation

protocol AccountInteractor {
	func loadAccount()
	func clearAccount()
	func updateAccount(to account: AccountV2)
	func login(_ loginData: LoginData) -> AnyPublisher<AccountV2, AccountRepositoryError>
	func signup(_ signupData: SignupData) -> AnyPublisher<AccountV2, AccountRepositoryError>
	func logout() -> AnyPublisher<Bool, AccountRepositoryError>
}

struct LiveAccountInteractor: AccountInteractor {
	let repository: AccountRepository
	let appState: Store<AppState>

	init(repository: AccountRepository, appState: Store<AppState>) {
		self.repository = repository
		self.appState = appState
	}

	func loadAccount() {
		// Only allow the account to be loaded once
		guard case .notLoaded = appState[\.account] else { return }

		let cancelBag = CancelBag()
		appState[\.account] = .loading(cached: nil, cancelBag: cancelBag)

		weak var weakState = appState
		repository.loadAccount()
			.sinkToLoadable { weakState?[\.account] = $0 }
			.store(in: cancelBag)
	}

	func clearAccount() {
		appState[\.account] = .failed(AccountRepositoryError.loggedOut)
	}

	func updateAccount(to account: AccountV2) {
		appState[\.account] = .loaded(account)
	}

	func logout() -> AnyPublisher<Bool, AccountRepositoryError> {
		repository.logout()
			.map {
				self.clearAccount()
				return $0
			}
			.eraseToAnyPublisher()
	}

	func login(_ loginData: LoginData) -> AnyPublisher<AccountV2, AccountRepositoryError> {
		repository.login(loginData)
	}

	func signup(_ signupData: SignupData) -> AnyPublisher<AccountV2, AccountRepositoryError> {
		repository.signup(signupData)
	}
}

struct StubAccountInteractor: AccountInteractor {
	func loadAccount() { }
	func clearAccount() { }
	func updateAccount(to account: AccountV2) { }
	func login(_ loginData: LoginData) -> AnyPublisher<AccountV2, AccountRepositoryError> {
		Just(AccountV2(userId: UUID(), token: ""))
			.mapError { _ in .loggedOut }
			.eraseToAnyPublisher()
	}

	func signup(_ signupData: SignupData) -> AnyPublisher<AccountV2, AccountRepositoryError> {
		Just(AccountV2(userId: UUID(), token: ""))
			.mapError { _ in .loggedOut }
			.eraseToAnyPublisher()
	}

	func logout() -> AnyPublisher<Bool, AccountRepositoryError> {
		Just(true)
			.mapError { _ in .loggedOut }
			.eraseToAnyPublisher()
	}
}
