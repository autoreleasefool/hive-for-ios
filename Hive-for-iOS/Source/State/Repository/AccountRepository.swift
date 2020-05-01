//
//  AccountRepository.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation
import KeychainAccess

enum AccountRepositoryError: Error {
	case notFound
	case keychainError(Error)
}

protocol AccountRepository {
	func loadAccount() -> AnyPublisher<AccountV2.Detail, AccountRepositoryError>
}

struct LiveAccountRepository: AccountRepository {
	private enum Key: String {
		case userId
		case token
	}

	private let keychain = Keychain(service: "ca.josephroque.hive-for-ios")

	func loadAccount() -> AnyPublisher<AccountV2.Detail, AccountRepositoryError> {
		Future { promise in
			do {
				guard let id = try self.keychain.get(Key.userId.rawValue),
					let userId = UUID(uuidString: id),
					let token = try self.keychain.get(Key.token.rawValue) else {
						return promise(.failure(AccountRepositoryError.notFound))
				}

				promise(.success(AccountV2.Detail(userId: userId, token: token)))
			} catch {
				print("Error retrieving login: \(error)")
				promise(.failure(.keychainError(error)))
			}
		}
		.eraseToAnyPublisher()
	}
}
