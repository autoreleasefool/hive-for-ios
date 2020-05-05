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
	case apiError(HiveAPIError)
	case loggedOut
}

protocol AccountRepository {
	func loadAccount() -> AnyPublisher<AccountV2, AccountRepositoryError>
	func login(_ loginData: LoginData) -> AnyPublisher<AccountV2, AccountRepositoryError>
	func signup(_ signupData: SignupData) -> AnyPublisher<AccountV2, AccountRepositoryError>
	func logout(fromAccount account: AccountV2) -> AnyPublisher<Bool, AccountRepositoryError>
}

struct LiveAccountRepository: AccountRepository {
	private enum Key: String {
		case userId
		case token
	}

	private let keychain: Keychain
	private let api: HiveAPI

	init(keychain: Keychain, api: HiveAPI) {
		self.keychain = keychain
		self.api = api
	}

	func loadAccount() -> AnyPublisher<AccountV2, AccountRepositoryError> {
		Future<AccountV2, AccountRepositoryError> { promise in
			do {
				guard let id = try self.keychain.get(Key.userId.rawValue),
					let userId = UUID(uuidString: id),
					let token = try self.keychain.get(Key.token.rawValue) else {
						return promise(.failure(AccountRepositoryError.notFound))
				}

				promise(.success(AccountV2(userId: userId, token: token)))
			} catch {
				print("Error retrieving login: \(error)")
				promise(.failure(.keychainError(error)))
			}
		}
		.flatMap { account in
			self.api.checkToken(userId: account.userId, token: account.token)
				.mapError { .apiError($0) }
				.map { _ in account }
		}
		.eraseToAnyPublisher()
	}

	func login(_ loginData: LoginData) -> AnyPublisher<AccountV2, AccountRepositoryError> {
		self.api.login(login: loginData)
			.mapError { .apiError($0) }
			.map { AccountV2(userId: $0.userId, token: $0.token) }
			.eraseToAnyPublisher()
	}

	func signup(_ signupData: SignupData) -> AnyPublisher<AccountV2, AccountRepositoryError> {
		self.api.signup(signup: signupData)
			.mapError { .apiError($0) }
			.map { AccountV2(userId: $0.accessToken.userId, token: $0.accessToken.token) }
			.eraseToAnyPublisher()
	}

	func logout(fromAccount account: AccountV2) -> AnyPublisher<Bool, AccountRepositoryError> {
		self.api.logout(fromAccount: account)
			.mapError { .apiError($0) }
			.eraseToAnyPublisher()
	}
}
