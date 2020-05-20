//
//  UserInteractor.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation

protocol UserInteractor {
	func loadProfile()
	func loadDetails(id: User.ID, user: LoadableSubject<User>)
}

struct LiveUserInteractor: UserInteractor {
	let repository: UserRepository
	let appState: Store<AppState>

	func loadProfile() {
		guard let id = appState.value.account.value?.userId else {
			appState[\.userProfile] = .failed(UserRepositoryError.missingID)
			return
		}

		let cancelBag = CancelBag()
		appState[\.userProfile].setLoading(cancelBag: cancelBag)

		weak var weakState = appState
		repository.loadDetails(id: id, withAccount: appState.value.account.value)
			.receive(on: DispatchQueue.main)
			.sinkToLoadable { weakState?[\.userProfile] = $0 }
			.store(in: cancelBag)
	}

	func loadDetails(id: User.ID, user: LoadableSubject<User>) {
		let cancelBag = CancelBag()
		user.wrappedValue.setLoading(cancelBag: cancelBag)

		repository.loadDetails(id: id, withAccount: appState.value.account.value)
			.receive(on: DispatchQueue.main)
			.sinkToLoadable { user.wrappedValue = $0 }
			.store(in: cancelBag)
	}
}

struct StubUserInteractor: UserInteractor {
	func loadProfile() { }
	func loadDetails(id: User.ID, user: LoadableSubject<User>) { }
}
