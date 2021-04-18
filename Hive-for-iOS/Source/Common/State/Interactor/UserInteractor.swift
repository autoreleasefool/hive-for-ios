//
//  UserInteractor.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation
import HiveFoundation

protocol UserInteractor {
	func loadProfile(user: LoadableSubject<User>)
	func loadDetails(id: User.ID, user: LoadableSubject<User>)
	func loadUsers(filter: String?, users: LoadableSubject<[User]>)
	func updateProfile(_ data: User.Update.Request, user: LoadableSubject<User>)
}

struct LiveUserInteractor: UserInteractor {
	let repository: UserRepository
	let appState: Store<AppState>

	func loadProfile(user: LoadableSubject<User>) {
		guard let id = appState.value.account.value?.id else {
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

	func loadUsers(filter: String?, users: LoadableSubject<[User]>) {
		let cancelBag = CancelBag()
		users.wrappedValue.setLoading(cancelBag: cancelBag)

		repository.loadUsers(filter: filter, withAccount: appState.value.account.value)
			.receive(on: RunLoop.main)
			.sinkToLoadable { users.wrappedValue = $0 }
			.store(in: cancelBag)
	}

	func updateProfile(_ data: User.Update.Request, user: LoadableSubject<User>) {
		let cancelBag = CancelBag()
		user.wrappedValue.setLoading(cancelBag: cancelBag)

		repository.updateProfile(data, withAccount: appState.value.account.value)
			.receive(on: RunLoop.main)
			.sinkToLoadable { user.wrappedValue = $0 }
			.store(in: cancelBag)
	}
}

struct StubUserInteractor: UserInteractor {
	func loadProfile(user: LoadableSubject<User>) { }
	func loadDetails(id: User.ID, user: LoadableSubject<User>) { }
	func loadUsers(filter: String?, users: LoadableSubject<[User]>) { }
	func updateProfile(_ data: User.Update.Request, user: LoadableSubject<User>) { }
}
