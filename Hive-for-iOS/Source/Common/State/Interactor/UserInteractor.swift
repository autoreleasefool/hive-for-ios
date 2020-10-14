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
	func loadProfile(user: LoadableSubject<User>)
	func loadDetails(id: User.ID, user: LoadableSubject<User>)
}

struct LiveUserInteractor: UserInteractor {
	let repository: UserRepository
	let appState: Store<AppState>

	func loadProfile(user: LoadableSubject<User>) {
		guard let id = appState.value.account.value?.userId else {
			user.wrappedValue = .failed(UserRepositoryError.missingID)
			return
		}

		return loadDetails(id: id, user: user)
	}

	func loadDetails(id: User.ID, user: LoadableSubject<User>) {
		let cancelBag = CancelBag()
		user.wrappedValue.setLoading(cancelBag: cancelBag)

		repository.loadDetails(id: id, withAccount: appState.value.account.value)
			.receive(on: RunLoop.main)
			.sinkToLoadable { user.wrappedValue = $0 }
			.store(in: cancelBag)
	}
}

struct StubUserInteractor: UserInteractor {
	func loadProfile(user: LoadableSubject<User>) { }
	func loadDetails(id: User.ID, user: LoadableSubject<User>) { }
}
