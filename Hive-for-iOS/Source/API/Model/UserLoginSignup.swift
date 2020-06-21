//
//  UserLoginSignup.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

// MARK: - Signup

extension User {
	enum Signup {}
}

extension User.Signup {
	struct Request: Codable {
		let email: String
		let displayName: String
		let password: String
		let verifyPassword: String
	}

	struct Response: Decodable {
		let id: User.ID
		let email: String
		let displayName: String
		let avatarUrl: String?
		let token: SessionToken
	}
}

// MARK: - Login

extension User {
	enum Login {}
}

extension User.Login {
	struct Request: Codable {
		let email: String
		let password: String
	}
}

// MARK: - Logout

extension User {
	enum Logout {}
}

extension User.Logout {
	struct Response: Codable {
		let success: Bool
	}
}
