//
//  AccountInteractor.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

protocol AccountInteractor {
	func loadAccount()
}

struct LiveAccountInteractor: AccountInteractor {
	let repository: AccountRepository
	let appState: Store<AppState>

	init(repository: AccountRepository, appState: Store<AppState>) {
		self.repository = repository
		self.appState = appState
	}

	func loadAccount() {
		let cancelBag = CancelBag()
		appState.value.account.detail = .loading(cached: nil, cancelBag: cancelBag)

		weak var weakState = appState
		repository.loadAccount()
			.sinkToLoadable { weakState?.value.account.detail = $0 }
			.store(in: cancelBag)
	}
}

struct StubAccountInteractor: AccountInteractor {
	func loadAccount() { }
}
