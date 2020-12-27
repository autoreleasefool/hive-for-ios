//
//  Endpoint.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-12-27.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

extension HiveAPI {
	enum Endpoint {
		// Auth
		case login(User.Login.Request)
		case signInWithApple(User.SignInWithApple.Request)
		case signup(User.Signup.Request)
		case updateAccount(User.Update.Request)
		case createGuestAccount
		case logout(Account)
		case checkToken(Account)

		// Users
		case userDetails(User.ID)
		case filterUsers(String?)

		// Matches
		case matchDetails(Match.ID)
		case openMatches
		case activeMatches
		case joinMatch(Match.ID)
		case createMatch

		var path: String {
			switch self {
			case .login: return "users/login"
			case .signup: return "users/signup"
			case .logout: return "users/logout"
			case .updateAccount: return "users/update"
			case .checkToken: return "users/validate"
			case .createGuestAccount: return "users/guestSignup"
			case .signInWithApple: return "siwa/auth"

			case .userDetails(let id): return "users/\(id.uuidString)/details"
			case .filterUsers: return "users/all"

			case .matchDetails(let id): return "matches/\(id.uuidString)/details"
			case .openMatches: return "matches/open"
			case .activeMatches: return "matches/active"
			case .joinMatch(let id): return "matches/\(id.uuidString)/join"
			case .createMatch: return "matches/new"
			}
		}

		var queryParams: [String: String]? {
			switch self {
			case
				.activeMatches,
				.checkToken,
				.createMatch,
				.joinMatch,
				.login,
				.logout,
				.matchDetails,
				.openMatches,
				.signup,
				.userDetails,
				.createGuestAccount,
				.signInWithApple,
				.updateAccount:
				return nil
			case .filterUsers(let filter):
				if let filter = filter {
					return ["filter": filter]
				} else {
					return nil
				}
			}
		}

		var headers: [String: String] {
			switch self {
			case .login(let data):
				let auth = String(format: "%@:%@", data.email, data.password)
				let authData = auth.data(using: String.Encoding.utf8)!
				let base64Auth = authData.base64EncodedString()
				return ["Authorization": "Basic \(base64Auth)"]
			case
				.logout(let account),
				.checkToken(let account):
				return account.headers
			case
				.updateAccount,
				.signInWithApple,
				.signup,
				.createGuestAccount,
				.openMatches,
				.activeMatches,
				.userDetails,
				.matchDetails,
				.joinMatch,
				.createMatch,
				.filterUsers:
				return [:]
			}
		}

		var httpMethod: HTTPMethod {
			switch self {
			case
				.login,
				.signup,
				.createGuestAccount,
				.createMatch,
				.joinMatch,
				.updateAccount,
				.signInWithApple:
				return .post
			case
				.logout:
				return .delete
			case
				.checkToken,
				.openMatches,
				.activeMatches,
				.userDetails,
				.matchDetails,
				.filterUsers:
				return .get
			}
		}
	}
}
