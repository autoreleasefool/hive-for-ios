//
//  AccountV2.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

extension NSNotification.Name {
	enum Account {
		static let Unauthorized = Notification.Name("Account.Unauthorized")
	}
}

struct AccountV2: Equatable {
	var userId: User.ID
	var token: String

	func applyAuth(to request: inout URLRequest, overridingTokenWith token: String? = nil) {
		AccountV2.apply(auth: self, to: &request, overridingTokenWith: token)
	}

	static func apply(auth: AccountV2?, to request: inout URLRequest, overridingTokenWith token: String? = nil) {
		guard let token = token ?? auth?.token else { return }
		request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
	}
}
