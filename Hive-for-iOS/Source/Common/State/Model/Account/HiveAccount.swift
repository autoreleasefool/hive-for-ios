//
//  HiveAccount.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-12-21.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

struct HiveAccount: Account, Equatable {
	private static let offlineId = UUID(uuidString: "602c977d-168a-4771-8599-9f35ed1abd41")!
	private static let offlineToken = "offline"

	static let offline: Account = HiveAccount(
		id: offlineId,
		token: offlineToken,
		isGuest: false
	)

	let id: User.ID
	let token: String
	let isGuest: Bool

	var isOffline: Bool {
		return id == HiveAccount.offlineId
	}

	var headers: [String: String] {
		["Authorization": "Bearer \(token)"]
	}

	func applyAuth(to request: inout URLRequest) {
		request.addValue("Bearer: \(token)", forHTTPHeaderField: "Authorization")
	}
}
