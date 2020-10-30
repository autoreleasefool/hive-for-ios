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
	func createGuestAccount() -> AnyPublisher<Account, AccountRepositoryError>
	func logout(fromAccount account: Account) -> AnyPublisher<Bool, AccountRepositoryError>
}

struct LiveAccountRepository: AccountRepository {
	private enum Key: String {
		case account
	}

	private let keychain: Keychain
	private let api: HiveAPI

	private let accountEncoder = JSONEncoder()
	private let accountDecoder = JSONDecoder()

	init(keychain: Keychain, api: HiveAPI) {
		self.keychain = keychain
		self.api = api
	}

	func loadAccount() -> AnyPublisher<Account, AccountRepositoryError> {
		Future<Account, AccountRepositoryError> { promise in
			do {
				guard let accountData = try keychain.getData(Key.account.rawValue),
					let account = try? accountDecoder.decode(Account.self, from: accountData) else {
					return promise(.failure(AccountRepositoryError.notFound))
				}
				promise(.success(account))
			} catch {
				logger.error("Error retrieving login: \(error)")
				promise(.failure(.keychainError(error)))
			}
		}
		.flatMap { account in
			api.fetch(.checkToken(account))
				.mapError { .apiError($0) }
				.map { (_: SessionToken) in account }
		}
		.eraseToAnyPublisher()
	}

	func clearAccount() {
		do {
			try keychain.remove(Key.account.rawValue)
		} catch {
			logger.error("Failed to clear account: \(error)")
		}
	}

	func saveAccount(_ account: Account) {
		guard !account.isOffline, !account.isGuest else { return }

		do {
			let accountData = try accountEncoder.encode(account)
			try keychain.set(accountData, key: Key.account.rawValue)
		} catch {
			logger.error("Error saving login: \(error)")
		}
	}

	func login(_ loginData: User.Login.Request) -> AnyPublisher<Account, AccountRepositoryError> {
		api.fetch(.login(loginData))
			.mapError { .apiError($0) }
			.map { (token: SessionToken) in Account(userId: token.userId, token: token.token, isGuest: false) }
			.eraseToAnyPublisher()
	}

	func signup(_ signupData: User.Signup.Request) -> AnyPublisher<Account, AccountRepositoryError> {
		api.fetch(.signup(signupData))
			.mapError { .apiError($0) }
			.map { (result: User.Signup.Response) in
				Account(userId: result.token.userId, token: result.token.token, isGuest: false)
			}
			.eraseToAnyPublisher()
	}

	func createGuestAccount() -> AnyPublisher<Account, AccountRepositoryError> {
		api.fetch(.createGuestAccount)
			.mapError { .apiError($0) }
			.map { (result: User.Signup.Response) in
				Account(userId: result.token.userId, token: result.token.token, isGuest: true)
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
