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

struct Account: Equatable, Codable {
	private static let offlineId = UUID(uuidString: "602c977d-168a-4771-8599-9f35ed1abd41")!
	private static let offlineToken = "offline"
	static let offline: Account = Account(userId: offlineId, token: offlineToken, isGuest: false)

	let userId: User.ID
	let token: String
	let isGuest: Bool

	var headers: [String: String] {
		return ["Authorization": "Bearer \(token)"]
	}

	var isOffline: Bool {
		return userId == Account.offlineId || token == Account.offlineToken
	}

	func applyAuth(to request: inout URLRequest, overridingTokenWith token: String? = nil) {
		Account.apply(auth: self, to: &request, overridingTokenWith: token)
	}

	static func apply(auth: Account?, to request: inout URLRequest, overridingTokenWith token: String? = nil) {
		guard let token = token ?? auth?.token else { return }
		request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
	}
}
