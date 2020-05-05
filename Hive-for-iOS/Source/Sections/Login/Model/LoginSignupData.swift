//
//  LoginSignupData.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-30.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

struct LoginData: Codable {
	let email: String
	let password: String
}

struct SignupData: Codable {
	let email: String
	let displayName: String
	let password: String
	let verifyPassword: String
}
