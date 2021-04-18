//
//  UserRepository.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation
import HiveFoundation

enum UserRepositoryError: Error {
	case usingOfflineAccount
	case missingID
	case apiError(HiveAPIError)
}

protocol UserRepository {
	func loadDetails(id: User.ID, withAccount account: Account?) -> AnyPublisher<User, UserRepositoryError>
	func loadUsers(filter: String?, withAccount account: Account?) -> AnyPublisher<[User], UserRepositoryError>
	func updateProfile(_ data: User.Update.Request, withAccount account: Account?)
		-> AnyPublisher<User, UserRepositoryError>
}

struct LiveUserRepository: UserRepository {
	private let api: HiveAPI

	init(api: HiveAPI) {
		self.api = api
	}

	func loadDetails(id: User.ID, withAccount account: Account?) -> AnyPublisher<User, UserRepositoryError> {
		api.fetch(.userDetails(id), withAccount: account)
			.mapError { .apiError($0) }
			.eraseToAnyPublisher()
	}

	func loadUsers(filter: String?, withAccount account: Account?) -> AnyPublisher<[User], UserRepositoryError> {
		api.fetch(.filterUsers(filter), withAccount: account)
			.mapError { .apiError($0) }
			.eraseToAnyPublisher()
	}

	func updateProfile(
		_ data: User.Update.Request,
		withAccount account: Account?
	) -> AnyPublisher<User, UserRepositoryError> {
		api.fetch(.updateAccount(data), withAccount: account)
			.mapError { .apiError($0) }
			.eraseToAnyPublisher()
	}
}
