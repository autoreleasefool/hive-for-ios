//
//  UserSignup.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

struct SignupToken: Codable {
	let value: String
}

struct UserSignup: Codable {
	let id: UUID
	let email: String
	let displayName: String
	let avatarUrl: String?
	let token: SignupToken
}
