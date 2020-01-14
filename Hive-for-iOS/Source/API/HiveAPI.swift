//
//  HiveAPI.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

enum HiveAPIError: LocalizedError {
	case networkingError(Error)
	case invalidResponse
	case invalidHTTPResponse(Int)
	case invalidData
	case missingData

	var errorDescription: String? {
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
		}
	}
}

typealias HiveAPIResult<Success> = Result<Success, HiveAPIError>

struct HiveAPI {

	// MARK: - Rooms

	func rooms(completion: @escaping (HiveAPIResult<[Room]>) -> Void) {
		completion(.success(Room.rooms))
	}

	// MARK: - Common

	private func handleResponse<Result: Codable>(data: Data?, response: URLResponse?, error: Error?, completion: (HiveAPIResult<Result>) -> Void) {
		guard error == nil else {
			completion(.failure(.networkingError(error!)))
			return
		}

		guard let response = response as? HTTPURLResponse else {
			completion(.failure(.invalidResponse))
			return
		}

		guard (200..<400).contains(response.statusCode) else {
			completion(.failure(.invalidHTTPResponse(response.statusCode)))
			return
		}

		let decoder = JSONDecoder()
		guard let data = data, let result = try? decoder.decode(Result.self, from: data) else {
			completion(.failure(.invalidData))
			return
		}

		completion(.success(result))
	}

	private func handleVoidResponse(data: Data?, response: URLResponse?, error: Error?, completion: (HiveAPIResult<Bool>) -> Void) {
		guard error == nil else {
			completion(.failure(.networkingError(error!)))
			return
		}

		guard let response = response as? HTTPURLResponse else {
			completion(.failure(.invalidResponse))
			return
		}

		guard (200..<400).contains(response.statusCode) else {
			completion(.failure(.invalidHTTPResponse(response.statusCode)))
			return
		}

		completion(.success(true))
	}
}
