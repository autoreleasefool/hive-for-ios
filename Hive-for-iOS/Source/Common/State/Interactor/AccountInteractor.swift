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
	func login(_ loginData: LoginData, account: LoadableSubject<Account>)
	func signup(_ signupData: SignupData, account: LoadableSubject<Account>)
	func logout(fromAccount account: Account, result: LoadableSubject<Bool>)
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
		appState[\.account].setLoading(cancelBag: cancelBag)

		weak var weakState = appState
		repository.loadAccount()
			.receive(on: DispatchQueue.main)
			.sinkToLoadable { weakState?[\.account] = $0 }
			.store(in: cancelBag)
	}

	func clearAccount() {
		appState[\.account] = .failed(AccountRepositoryError.loggedOut)
	}

	func updateAccount(to account: Account) {
		appState[\.account] = .loaded(account)
		repository.saveAccount(account)
	}

	func logout(fromAccount account: Account, result: LoadableSubject<Bool>) {
		let cancelBag = CancelBag()
		result.wrappedValue.setLoading(cancelBag: cancelBag)

		repository.logout(fromAccount: account)
			.receive(on: DispatchQueue.main)
			.sinkToLoadable { result.wrappedValue = $0 }
			.store(in: cancelBag)
	}

	func login(_ loginData: LoginData, account: LoadableSubject<Account>) {
		let cancelBag = CancelBag()
		account.wrappedValue.setLoading(cancelBag: cancelBag)

		weak var weakState = appState
		repository.login(loginData)
			.receive(on: DispatchQueue.main)
			.sinkToLoadable {
				if case .loaded = $0, let account = $0.value {
					self.repository.saveAccount(account)
					weakState?[\.account] = $0
				}
				account.wrappedValue = $0
			 }
			.store(in: cancelBag)

	}

	func signup(_ signupData: SignupData, account: LoadableSubject<Account>) {
		let cancelBag = CancelBag()
		account.wrappedValue.setLoading(cancelBag: cancelBag)

		weak var weakState = appState
		repository.signup(signupData)
			.receive(on: DispatchQueue.main)
			.sinkToLoadable {
				if case .loaded = $0, let account = $0.value {
					self.repository.saveAccount(account)
					weakState?[\.account] = $0
				}
				account.wrappedValue = $0
			}
			.store(in: cancelBag)
	}
}

struct StubAccountInteractor: AccountInteractor {
	func loadAccount() { }
	func clearAccount() { }
	func login(_ loginData: LoginData, account: LoadableSubject<Account>) { }
	func signup(_ signupData: SignupData, account: LoadableSubject<Account>) { }
	func logout(fromAccount account: Account, result: LoadableSubject<Bool>) { }
}
