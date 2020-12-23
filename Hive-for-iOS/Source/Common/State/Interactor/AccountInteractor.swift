//
//  AccountInteractor.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import AuthenticationServices
import Combine
import Foundation

protocol AccountInteractor {
	func loadAccount()
	func clearAccount()
	func login(_ loginData: User.Login.Request, account: LoadableSubject<AnyAccount>)
	func signup(_ signupData: User.Signup.Request, account: LoadableSubject<AnyAccount>)
	func signInWithApple(_ appleData: User.SignInWithApple.Request, account: LoadableSubject<AnyAccount>?)
	func logout(fromAccount account: Account, result: LoadableSubject<Bool>)
	func playOffline(account: LoadableSubject<AnyAccount>?)
	func createGuestAccount(account: LoadableSubject<AnyAccount>?)

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
			.receive(on: RunLoop.main)
			.sinkToLoadable { weakState?[\.account] = $0 }
			.store(in: cancelBag)
	}

	func clearAccount() {
		appState[\.account] = .failed(AccountRepositoryError.loggedOut)
		repository.clearAccount()
	}

	func updateAccount(to account: Account) {
		appState[\.account] = .loaded(account.eraseToAnyAccount())
		repository.saveAccount(account)
	}

	func logout(fromAccount account: Account, result: LoadableSubject<Bool>) {
		guard !account.isOffline else {
			appState[\.account] = .failed(AccountRepositoryError.loggedOut)
			result.wrappedValue = .loaded(true)
			return
		}

		let cancelBag = CancelBag()
		result.wrappedValue.setLoading(cancelBag: cancelBag)

		weak var weakState = appState
		repository.logout(fromAccount: account)
			.receive(on: RunLoop.main)
			.sinkToLoadable {
				weakState?[\.account] = .failed(AccountRepositoryError.loggedOut)
				result.wrappedValue = $0
			}
			.store(in: cancelBag)
	}

	func login(_ loginData: User.Login.Request, account: LoadableSubject<AnyAccount>) {
		let cancelBag = CancelBag()
		account.wrappedValue.setLoading(cancelBag: cancelBag)

		weak var weakState = appState
		repository.login(loginData)
			.receive(on: RunLoop.main)
			.sinkToLoadable {
				if case .loaded = $0, let account = $0.value {
					repository.saveAccount(account)
					weakState?[\.account] = $0
				}
				account.wrappedValue = $0.eraseToAnyAccount()
			 }
			.store(in: cancelBag)

	}

	func signup(_ signupData: User.Signup.Request, account: LoadableSubject<AnyAccount>) {
		let cancelBag = CancelBag()
		account.wrappedValue.setLoading(cancelBag: cancelBag)

		weak var weakState = appState
		repository.signup(signupData)
			.receive(on: RunLoop.main)
			.sinkToLoadable {
				if case .loaded = $0, let account = $0.value {
					repository.saveAccount(account)
					weakState?[\.account] = $0
				}
				account.wrappedValue = $0.eraseToAnyAccount()
			}
			.store(in: cancelBag)
	}

	func playOffline(account: LoadableSubject<AnyAccount>?) {
		account?.wrappedValue = .loaded(HiveAccount.offline.eraseToAnyAccount())
		appState[\.account] = .loaded(HiveAccount.offline.eraseToAnyAccount())
	}

	func createGuestAccount(account: LoadableSubject<AnyAccount>?) {
		let cancelBag = CancelBag()
		account?.wrappedValue.setLoading(cancelBag: cancelBag)

		weak var weakState = appState
		repository.createGuestAccount()
			.receive(on: RunLoop.main)
			.sinkToLoadable {
				if case .loaded = $0, let account = $0.value {
					repository.saveAccount(account)
					weakState?[\.account] = $0
				}
				account?.wrappedValue = $0.eraseToAnyAccount()
			}
			.store(in: cancelBag)
	}

	func signInWithApple(
		_ appleData: User.SignInWithApple.Request,
		account: LoadableSubject<AnyAccount>?
	) {
		let cancelBag = CancelBag()
		account?.wrappedValue.setLoading(cancelBag: cancelBag)

		weak var weakState = appState
		repository.signInWithApple(appleData)
			.receive(on: RunLoop.main)
			.sinkToLoadable {
				if case .loaded = $0, let account = $0.value {
					repository.saveAccount(account)
					weakState?[\.account] = $0.eraseToAnyAccount()
				}
				account?.wrappedValue = $0.eraseToAnyAccount()
			}
			.store(in: cancelBag)
	}
}

struct StubAccountInteractor: AccountInteractor {
	func loadAccount() { }
	func clearAccount() { }
	func login(_ loginData: User.Login.Request, account: LoadableSubject<AnyAccount>) { }
	func signup(_ signupData: User.Signup.Request, account: LoadableSubject<AnyAccount>) { }
	func logout(fromAccount account: Account, result: LoadableSubject<Bool>) { }
	func playOffline(account: LoadableSubject<AnyAccount>?) { }
	func createGuestAccount(account: LoadableSubject<AnyAccount>?) { }
	func signInWithApple(_ appleData: User.SignInWithApple.Request, account: LoadableSubject<AnyAccount>?) { }
}
