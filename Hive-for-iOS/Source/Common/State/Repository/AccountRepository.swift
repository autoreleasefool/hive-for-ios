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
	func loadAccount() -> AnyPublisher<Account, AccountRepositoryError>
	func clearAccount()

	func saveAccount(_ account: Account)
	func login(_ loginData: User.Login.Request) -> AnyPublisher<Account, AccountRepositoryError>
	func signup(_ signupData: User.Signup.Request) -> AnyPublisher<Account, AccountRepositoryError>
	func logout(fromAccount account: Account) -> AnyPublisher<Bool, AccountRepositoryError>
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

	func loadAccount() -> AnyPublisher<Account, AccountRepositoryError> {
		Future<Account, AccountRepositoryError> { promise in
			do {
				guard let id = try self.keychain.get(Key.userId.rawValue),
					let userId = UUID(uuidString: id),
					let token = try self.keychain.get(Key.token.rawValue) else {
						return promise(.failure(AccountRepositoryError.notFound))
				}

				promise(.success(Account(userId: userId, token: token)))
			} catch {
				print("Error retrieving login: \(error)")
				promise(.failure(.keychainError(error)))
			}
		}
		.flatMap { account in
			self.api.fetch(.checkToken(account))
				.mapError { .apiError($0) }
				.map { (_: SessionToken) in account }
		}
		.eraseToAnyPublisher()
	}

	func clearAccount() {
		do {
			try self.keychain.remove(Key.userId.rawValue)
			try self.keychain.remove(Key.token.rawValue)
		} catch {
			print("Failed to clear account: \(error)")
		}
	}

	func saveAccount(_ account: Account) {
		do {
			try keychain.set(account.userId.uuidString, key: Key.userId.rawValue)
			try keychain.set(account.token, key: Key.token.rawValue)
		} catch {
			print("Error saving login: \(error)")
		}
	}

	func login(_ loginData: User.Login.Request) -> AnyPublisher<Account, AccountRepositoryError> {
		api.fetch(.login(loginData))
			.mapError { .apiError($0) }
			.map { (token: SessionToken) in Account(userId: token.userId, token: token.token) }
			.eraseToAnyPublisher()
	}

	func signup(_ signupData: User.Signup.Request) -> AnyPublisher<Account, AccountRepositoryError> {
		api.fetch(.signup(signupData))
			.mapError { .apiError($0) }
			.map { (result: User.Signup.Response) in
				Account(userId: result.token.userId, token: result.token.token)
			}
			.eraseToAnyPublisher()
	}

	func logout(fromAccount account: Account) -> AnyPublisher<Bool, AccountRepositoryError> {
		clearAccount()
		return api.fetch(.logout(account))
			.mapError { .apiError($0) }
			.map { (result: User.Logout.Response) in result.success }
			.eraseToAnyPublisher()
	}
}
