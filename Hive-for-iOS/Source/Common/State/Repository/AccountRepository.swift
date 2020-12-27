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
	func loadAccount() -> AnyPublisher<AnyAccount, AccountRepositoryError>
	func clearAccount()

	func saveAccount(_ account: Account)
	func login(_ loginData: User.Login.Request) -> AnyPublisher<AnyAccount, AccountRepositoryError>
	func signup(_ signupData: User.Signup.Request) -> AnyPublisher<AnyAccount, AccountRepositoryError>
	func createGuestAccount() -> AnyPublisher<AnyAccount, AccountRepositoryError>
	func signInWithApple(
		_ appleData: User.SignInWithApple.Request
	) -> AnyPublisher<AppleAccount, AccountRepositoryError>

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

	func loadAccount() -> AnyPublisher<AnyAccount, AccountRepositoryError> {
		Future<AnyAccount, AccountRepositoryError> { promise in
			do {
				guard let accountData = try keychain.getData(Key.account.rawValue),
					let account = try? accountDecoder.decode(AnyAccount.self, from: accountData) else {
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
				.map { (result: User.Authentication.Response) in
					NotificationCenter.default.post(name: NSNotification.Name.Account.Loaded, object: result.user)
					return account
				}
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
			let accountData = try accountEncoder.encode(AnyAccount(account))
			try keychain.set(accountData, key: Key.account.rawValue)
		} catch {
			logger.error("Error saving login: \(error)")
		}
	}

	func login(_ loginData: User.Login.Request) -> AnyPublisher<AnyAccount, AccountRepositoryError> {
		api.fetch(.login(loginData))
			.mapError { .apiError($0) }
			.map { (token: SessionToken) in
				HiveAccount(id: token.userId, token: token.token, isGuest: false)
					.eraseToAnyAccount()
			}
			.eraseToAnyPublisher()
	}

	func signup(_ signupData: User.Signup.Request) -> AnyPublisher<AnyAccount, AccountRepositoryError> {
		api.fetch(.signup(signupData))
			.mapError { .apiError($0) }
			.map { (result: User.Authentication.Response) in
				NotificationCenter.default.post(name: NSNotification.Name.Account.Created, object: result.user)
				return HiveAccount(id: result.user.id, token: result.accessToken, isGuest: result.user.isGuest)
					.eraseToAnyAccount()
			}
			.eraseToAnyPublisher()
	}

	func createGuestAccount() -> AnyPublisher<AnyAccount, AccountRepositoryError> {
		api.fetch(.createGuestAccount)
			.mapError { .apiError($0) }
			.map { (result: User.Authentication.Response) in
				NotificationCenter.default.post(name: NSNotification.Name.Account.Created, object: result.user)
				return HiveAccount(id: result.user.id, token: result.accessToken, isGuest: result.user.isGuest)
					.eraseToAnyAccount()
			}
			.eraseToAnyPublisher()
	}

	func signInWithApple(
		_ appleData: User.SignInWithApple.Request
	) -> AnyPublisher<AppleAccount, AccountRepositoryError> {
		api.fetch(.signInWithApple(appleData))
			.mapError { .apiError($0) }
			.map { (result: User.Authentication.Response) in
				NotificationCenter.default.post(name: NSNotification.Name.Account.Created, object: result.user)
				return AppleAccount(id: result.user.id, token: result.accessToken)
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
