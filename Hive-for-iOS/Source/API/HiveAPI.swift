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

	var errorDescription: String {
		switch self {
		case .networkingError:
			return "Network error"
		case .invalidResponse, .invalidData:
			return "Could not parse response"
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

struct HiveAPI {

	static let shared = HiveAPI()

	private init() { }

	// MARK: - Users

	func login(email: String, password: String) -> Future<AccessToken, HiveAPIError> {
		Future { promise in
			promise(.failure(.notImplemented))
		}
	}

	func signup(
		email: String,
		displayName: String,
		password: String,
		confirmPassword: String
	) -> Future<AccessToken, HiveAPIError> {
		Future { promise in
			promise(.failure(.notImplemented))
		}
	}

	func checkToken(userId: User.ID, token: String) -> Future<Bool, HiveAPIError> {
		Future { promise in
			promise(.failure(.notImplemented))
		}
	}

	func logout() -> Future<Void, HiveAPIError> {
		Future { promise in
			promise(.failure(.notImplemented))
		}
	}

	// MARK: - Rooms

	func rooms() -> Future<[Room], HiveAPIError> {
		Future { promise in
			promise(.success(Room.rooms))
//			if Bool.random() == true {
//				debugLog("Returning rooms")
//				promise(.success(Room.rooms))
//			} else {
//				debugLog("Returning error")
//				promise(.failure(.invalidResponse))
//			}
		}
	}

	func room(id: String) -> Future<Room, HiveAPIError> {
		Future { promise in
			if let room = Room.rooms.first(where: { $0.id == id }) {
				promise(.success(room))
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
