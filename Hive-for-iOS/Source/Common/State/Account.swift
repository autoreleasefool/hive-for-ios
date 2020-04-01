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

class Account: ObservableObject {
	private enum Key: String {
		case userID
		case accessToken
	}

	@Published var userID: User.ID? = nil
	@Published var accessToken: String? = "token"

	var accountLoaded = CurrentValueSubject<Bool, Never>(false)

	private let keychain = Keychain(service: "ca.josephroque.hive-for-ios")

	init() {
//		do {
//			guard let id = try keychain.get(Key.userID.rawValue) else { return }
//			guard let token = try keychain.get(Key.accessToken.rawValue) else { return }
//
//			userID = UUID(uuidString: id)
//			accessToken = token
//		} catch {
//			print("Error retrieving login: \(error)")
//		}
	}

	func store(userID: User.ID?) throws {
		if let userID = userID {
			try keychain.set(userID.uuidString, key: Key.userID.rawValue)
		} else {
			try keychain.remove(Key.userID.rawValue)
		}
	}

	func store(accessToken: String?) throws {
		if let accessToken = accessToken {
			try keychain.set(accessToken, key: Key.accessToken.rawValue)
		} else {
			try keychain.remove(Key.accessToken.rawValue)
		}
	}
}
