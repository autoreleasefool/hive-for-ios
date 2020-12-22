//
//  AppleAccount.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-12-21.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

struct AppleAccount: Account, Equatable {
	let id: User.ID
	let token: String

	var isGuest: Bool {
		false
	}

	var isOffline: Bool {
		false
	}

	func applyAuth(to request: inout URLRequest) {
		request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
	}
}
