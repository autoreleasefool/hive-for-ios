//
//  UserSignup.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

struct SignupToken: Decodable {
	let id: User.ID
	let value: String
}

struct UserSignup: Decodable {
	let id: User.ID
	let email: String
	let displayName: String
	let avatarUrl: String?
	let token: SignupToken

	var accessToken: AccessToken {
		AccessToken(id: token.id, userId: id, token: token.value)
	}
}
