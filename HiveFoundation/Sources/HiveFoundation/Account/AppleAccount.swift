//
//  AppleAccount.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2020-12-21.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

public struct AppleAccount: Account, Equatable {
	public let id: UUID
	public let token: String

	public init(id: UUID, token: String) {
		self.id = id
		self.token = token
	}

	public var isGuest: Bool {
		false
	}

	public var isOffline: Bool {
		false
	}

	public var headers: [String: String] {
		["Authorization": "Bearer \(token)"]
	}

	public func applyAuth(to request: inout URLRequest) {
		request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
	}
}
