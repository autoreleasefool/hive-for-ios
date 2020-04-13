//
//  AccessToken.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-30.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

struct AccessToken: Decodable {
	let id: UUID
	let userId: User.ID
	let token: String
}

struct TokenValidation: Decodable {
	let userId: UUID
	let token: String
}
