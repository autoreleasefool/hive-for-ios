//
//  Account.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

public extension NSNotification.Name {
	enum Account {
		public static let Unauthorized = Notification.Name("Account.Unauthorized")
		public static let Created = Notification.Name("Account.Created")
		public static let Loaded = Notification.Name("Account.Loaded")
	}
}

public protocol Account: Codable {
	var id: UUID { get }
	var token: String { get }
	var isGuest: Bool { get }
	var isOffline: Bool { get }
	var headers: [String: String] { get }

	func applyAuth(to request: inout URLRequest)
	func eraseToAnyAccount() -> AnyAccount
}

extension Account {
	public func eraseToAnyAccount() -> AnyAccount {
		return AnyAccount(self)
	}
}
