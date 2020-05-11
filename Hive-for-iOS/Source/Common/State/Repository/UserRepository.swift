//
//  UserRepository.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation

enum UserRepositoryError: Error {
	case missingID
	case apiError(HiveAPIError)
}

protocol UserRepository {
	func loadDetails(id: User.ID, withAccount account: Account?) -> AnyPublisher<User, UserRepositoryError>
}

struct LiveUserRepository: UserRepository {
	private let api: HiveAPI

	init(api: HiveAPI) {
		self.api = api
	}

	func loadDetails(id: User.ID, withAccount account: Account?) -> AnyPublisher<User, UserRepositoryError> {
		api.user(id: id, withAccount: account)
			.mapError { .apiError($0) }
			.eraseToAnyPublisher()
	}
}
