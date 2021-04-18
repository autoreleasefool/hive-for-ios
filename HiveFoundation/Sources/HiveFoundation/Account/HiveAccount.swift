//
//  HiveAccount.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2020-12-21.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

public struct HiveAccount: Account, Equatable {
	private static let offlineId = UUID(uuidString: "602c977d-168a-4771-8599-9f35ed1abd41")!
	private static let offlineToken = "offline"

	public static let offline: Account = HiveAccount(
		id: offlineId,
		token: offlineToken,
		isGuest: false
	)

	public let id: UUID
	public let token: String
	public let isGuest: Bool

	public init(id: UUID, token: String, isGuest: Bool) {
		self.id = id
		self.token = token
		self.isGuest = isGuest
	}

	public var isOffline: Bool {
		return id == HiveAccount.offlineId
	}

	public var headers: [String: String] {
		["Authorization": "Bearer \(token)"]
	}

	public func applyAuth(to request: inout URLRequest) {
		request.addValue("Bearer: \(token)", forHTTPHeaderField: "Authorization")
	}
}
