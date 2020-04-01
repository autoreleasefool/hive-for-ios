//
//  HiveAPI.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import Combine
import Loaf

enum HiveAPIError: LocalizedError {
	case networkingError(Error)
	case invalidResponse
	case invalidHTTPResponse(Int)
	case invalidData
	case missingData
	case notImplemented
	case unauthorized

	var errorDescription: String {
		switch self {
		case .networkingError:
			return "Network error"
		case .invalidResponse, .invalidData:
			return "Could not parse response"
		case .unauthorized:
			return "Unauthorized"
		case .invalidHTTPResponse(let code):
			if (500..<600).contains(code) {
				return "Server error (\(code))"
			} else {
				return "Unexpected HTTP error (\(code))"
			}
		case .missingData:
			return "Could not find data"
		case .notImplemented:
			return "The method has not been implemented"
		}
	}

	var loaf: Loaf {
		Loaf(self.errorDescription, state: .error)
	}
}

typealias HiveAPIPromise<Success> = Future<Success, HiveAPIError>.Promise

class HiveAPI {
	private static let baseURL = URL(string: "")!

	static let shared = HiveAPI()

	private var apiGroup: URL { HiveAPI.baseURL.appendingPathComponent("api") }
	private var userGroup: URL { apiGroup.appendingPathComponent("users") }
	private var matchGroup: URL { apiGroup.appendingPathComponent("matches") }

	private init() { }

	// MARK: - Authentication

	private var account: Account!

	func set(account: Account) {
		self.account = account
	}

	private func applyAuth(to request: inout URLRequest) {
		guard let accessToken = account.accessToken else { return }
		request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
	}

	// MARK: - Users

	func login(login: LoginData) -> Future<AccessToken, HiveAPIError> {
		Future { promise in
			let url = self.userGroup.appendingPathComponent("login")

			let auth = String(format: "%@:%@", login.email, login.password)
			let authData = auth.data(using: String.Encoding.utf8)!
			let base64Auth = authData.base64EncodedString()

			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")

			URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
				self?.handleResponse(data: data, response: response, error: error, promise: promise)
			}.resume()
		}
	}

	func signup(signup: SignupData) -> Future<UserSignup, HiveAPIError> {
		Future { promise in
			let url = self.userGroup.appendingPathComponent("signup")

			let encoder = JSONEncoder()
			guard let signupData = try? encoder.encode(signup) else {
				return promise(.failure(.invalidData))
			}

			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.httpBody = signupData

			URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
				self?.handleResponse(data: data, response: response, error: error, promise: promise)
			}.resume()
		}
	}

	func checkToken(userId: User.ID, token: String) -> Future<Bool, HiveAPIError> {
		Future { promise in
			promise(.failure(.notImplemented))
		}
	}

	func logout() -> Future<Bool, HiveAPIError> {
		Future { promise in
			let url = self.userGroup.appendingPathComponent("logout")

			var request = URLRequest(url: url)
			request.httpMethod = "DELETE"
			self.applyAuth(to: &request)

			URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
				self?.handleVoidResponse(data: data, response: response, error: error, promise: promise)
			}.resume()
		}
	}

	// MARK: - Matches

	func openMatches() -> Future<[Match], HiveAPIError> {
		Future { promise in
			promise(.success(Match.matches))
//			if Bool.random() == true {
//				debugLog("Returning rooms")
//				promise(.success(Room.rooms))
//			} else {
//				debugLog("Returning error")
//				promise(.failure(.invalidResponse))
//			}
		}
	}

	func match(id: String) -> Future<Match, HiveAPIError> {
		Future { promise in
			if let match = Match.matches.first(where: { $0.id == id }) {
				promise(.success(match))
			} else {
				promise(.failure(.invalidData))
			}
		}
	}

	// MARK: - Common

	private func handleResponse<Result: Codable>(
		data: Data?,
		response: URLResponse?,
		error: Error?,
		promise: HiveAPIPromise<Result>
	) {
		guard error == nil else {
			return promise(.failure(.networkingError(error!)))
		}

		guard let response = response as? HTTPURLResponse else {
			return promise(.failure(.invalidResponse))
		}

		guard (200..<400).contains(response.statusCode) else {
			if response.statusCode == 401 {
				return promise(.failure(.unauthorized))
			}
			return promise(.failure(.invalidHTTPResponse(response.statusCode)))
		}

		let decoder = JSONDecoder()
		guard let data = data, let result = try? decoder.decode(Result.self, from: data) else {
			return promise(.failure(.invalidData))
		}

		promise(.success(result))
	}

	private func handleVoidResponse(data: Data?, response: URLResponse?, error: Error?, promise: HiveAPIPromise<Bool>) {
		guard error == nil else {
			return promise(.failure(.networkingError(error!)))
		}

		guard let response = response as? HTTPURLResponse else {
			return promise(.failure(.invalidResponse))
		}

		guard (200..<400).contains(response.statusCode) else {
			return promise(.failure(.invalidHTTPResponse(response.statusCode)))
		}

		promise(.success(true))
	}
}
