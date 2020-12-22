//
//  Account.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

extension NSNotification.Name {
	enum Account {
		static let Unauthorized = Notification.Name("Account.Unauthorized")
		static let SignupSuccess = Notification.Name("Account.SignupSuccess")
	}
}

protocol Account: Codable {
	var id: User.ID { get }
	var token: String { get }
	var isGuest: Bool { get }
	var isOffline: Bool { get }

	func applyAuth(to request: inout URLRequest)
	func eraseToAnyAccount() -> AnyAccount
}

extension Account {
	func eraseToAnyAccount() -> AnyAccount {
		return AnyAccount(self)
	}
}
