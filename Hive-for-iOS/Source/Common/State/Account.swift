//
//  Account.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import Combine
import KeychainAccess

enum TokenStatus {
	case validating
	case valid
	case invalid
	case validationError
}

class Account: ObservableObject {
	private static let debugAccountEnabled: Bool = false

	private enum Key: String {
		case userId
		case token
	}

	private(set) var userId: User.ID?
	private(set) var token: String?

	private var tokenValidation: AnyCancellable?

	@Published var isAuthenticated: Bool = false
	@Published var tokenStatus: TokenStatus?

	private let keychain = Keychain(service: "ca.josephroque.hive-for-ios")

	init() {
		if Account.debugAccountEnabled {
			try? store(userId: UUID(uuidString: "60448917-d472-4099-b1c8-956935245d6e"))
			try? store(token: "w6d9J8nap70BhiB63ZTyAQ==")
		}

		do {
			guard let id = try keychain.get(Key.userId.rawValue) else { return }
			guard let token = try keychain.get(Key.token.rawValue) else { return }

			userId = UUID(uuidString: id)
			self.token = token
			validateTokenOnStartup()
		} catch {
			print("Error retrieving login: \(error)")
		}
	}

	func clear() throws {
		try store(userId: nil)
		try store(token: nil)

		DispatchQueue.main.async {
			self.isAuthenticated = false
		}
	}

	func store(accessToken: AccessToken) throws {
		try store(userId: accessToken.userId)
		try store(token: accessToken.token)

		DispatchQueue.main.async {
			self.isAuthenticated = true
		}
	}

	private func store(userId: User.ID?) throws {
		if let userId = userId {
			try keychain.set(userId.uuidString, key: Key.userId.rawValue)
		} else {
			try keychain.remove(Key.userId.rawValue)
		}
	}

	private func store(token: String?) throws {
		if let token = token {
			try keychain.set(token, key: Key.token.rawValue)
		} else {
			try keychain.remove(Key.token.rawValue)
		}
	}

	private func validateTokenOnStartup() {
		guard let userId = self.userId, let token = self.token else { return }
		tokenStatus = .validating
		tokenValidation = HiveAPI
			.shared
			.checkToken(userId: userId, token: token)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] result in
					if case let .failure(error) = result {
						self?.handle(error: error)
					}
				},
				receiveValue: { [weak self] result in
					self?.tokenStatus = result ? .valid : .invalid
					self?.isAuthenticated = result
				}
			)
	}

	private func handle(error: HiveAPIError) {
		assert(Thread.isMainThread, "Account error not handled on the main thread")

		switch error {
		case .invalidData, .invalidResponse, .missingData, .notImplemented, .unauthorized:
			tokenStatus = .invalid
		case .invalidHTTPResponse(let code):
			print("Token validation failed: \(code)")
			tokenStatus = .validationError
		case .networkingError(let networkError):
			print("Token validation failed: \(networkError)")
			tokenStatus = .validationError
		}
	}
}
