//
//  AccessToken.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-30.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

struct AccessToken: Codable {
	let id: UUID
	let userId: User.ID
	let token: String
}

struct TokenValidation: Codable {
	let id: UUID
	let token: String
}
