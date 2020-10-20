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
	case usingOfflineAccount

	var errorDescription: String? {
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
		case .usingOfflineAccount:
			return "Currently offline"
		}
	}

	var loaf: LoafState {
		LoafState(errorDescription ?? "Unknown (API Error)", state: .error)
	}
}

typealias HiveAPIPromise<Success> = Future<Success, HiveAPIError>.Promise

class HiveAPI: ObservableObject {
	static let baseURL = URL(string: "https://hive.josephroque.dev")!

	private let session: URLSession
	private let apiQueue: DispatchQueue

	private let encoder: JSONEncoder = {
		var encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		return encoder
	}()

	private let decoder: JSONDecoder = {
		var decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}()

	init(session: URLSession = URLSession.shared, queue: DispatchQueue = .global(qos: .userInitiated)) {
		self.session = session
		self.apiQueue = queue
	}

	func fetch<Output: Decodable>(
		_ endpoint: Endpoint,
		withAccount account: Account? = nil
	) -> AnyPublisher<Output, HiveAPIError> {
		guard account?.isOffline != true else {
			return Fail(error: .usingOfflineAccount).eraseToAnyPublisher()
		}

		let url = HiveAPI.baseURL
			.appendingPathComponent("api")
			.appendingPathComponent(endpoint.path)

		var request = buildBaseRequest(to: url, withAccount: account)
		request.httpMethod = endpoint.httpMethod.rawValue
		for (header, value) in endpoint.headers {
			request.addValue(value, forHTTPHeaderField: header)
		}

		do {
			if let body = try body(for: endpoint) {
				request.httpBody = body
			}
		} catch {
			return Fail(error: .invalidData)
				.eraseToAnyPublisher()
		}

		return session.dataTaskPublisher(for: request)
			.subscribe(on: apiQueue)
			.tryMap { data, response in
				guard let httpResponse = response as? HTTPURLResponse else {
					throw HiveAPIError.invalidResponse
				}

				guard (200..<400).contains(httpResponse.statusCode) else {
					throw HiveAPIError.invalidHTTPResponse(httpResponse.statusCode)
				}

				return data
			}
			.decode(type: Output.self, decoder: decoder)
			.mapError {
				if let apiError = $0 as? HiveAPIError {
					if case .invalidHTTPResponse(401) = apiError {
						self.reportUnauthorizedRequest()
						return .unauthorized
					}
					return apiError
				}
				return .networkingError($0)
			}
			.eraseToAnyPublisher()
	}

	private func body(for endpoint: Endpoint) throws -> Data? {
		switch endpoint {
		case .login(let data):
			return try encoder.encode(data)
		case .signup(let data):
			return try encoder.encode(data)
		case .openMatches, .activeMatches, .checkToken, .logout, .userDetails, .matchDetails, .joinMatch, .createMatch, .filterUsers:
			return nil
		}
	}

	private func buildBaseRequest(to url: URL, withAccount account: Account? = nil) -> URLRequest {
		var request = URLRequest(url: url)
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		account?.applyAuth(to: &request)
		return request
	}

	private func reportUnauthorizedRequest() {
		NotificationCenter.default.post(name: NSNotification.Name.Account.Unauthorized, object: nil)
	}
}

// MARK: - Endpoint

extension HiveAPI {
	enum Endpoint {
		// Auth
		case login(User.Login.Request)
		case signup(User.Signup.Request)
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
			case .checkToken: return "users/validate"

			case .userDetails(let id): return "users/\(id.uuidString)/details"
			case .filterUsers(let filter): return "users/all?filter=\(filter ?? "")"

			case .matchDetails(let id): return "matches/\(id.uuidString)/details"
			case .openMatches: return "matches/open"
			case .activeMatches: return "matches/active"
			case .joinMatch(let id): return "matches/\(id.uuidString)/join"
			case .createMatch: return "matches/new"
			}
		}

		var headers: [String: String] {
			switch self {
			case .login(let data):
				let auth = String(format: "%@:%@", data.email, data.password)
				let authData = auth.data(using: String.Encoding.utf8)!
				let base64Auth = authData.base64EncodedString()
				return ["Authorization": "Basic \(base64Auth)"]
			case .logout(let account), .checkToken(let account):
				return account.headers
			case .signup, .openMatches, .activeMatches, .userDetails, .matchDetails, .joinMatch, .createMatch, .filterUsers:
				return [:]
			}
		}

		var httpMethod: HTTPMethod {
			switch self {
			case .login, .signup, .createMatch, .joinMatch: return .post
			case .logout: return .delete
			case .checkToken, .openMatches, .activeMatches, .userDetails, .matchDetails, .filterUsers: return .get
			}
		}
	}
}

// MARK: - HTTP Method

extension HiveAPI {
	enum HTTPMethod: String {
		case get = "GET"
		case post = "POST"
		case delete = "DELETE"
	}
}
