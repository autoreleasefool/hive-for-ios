//
//  HiveAPI.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import Combine

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

typealias HiveAPIPromise<Success> = Future<Success, HiveAPIError>.Promise

struct HiveAPI {

	// MARK: - Rooms

	func rooms() -> Future<[RoomPreview], HiveAPIError> {
		return Future { promise in
			promise(.success(Room.roomPreviews))
		}
	}

	func roomDetails(id: String) -> Future<Room, HiveAPIError> {
		return Future { promise in
			promise(.success(Room.testRoom))
		}
	}

	// MARK: - Common

	private func handleResponse<Result: Codable>(data: Data?, response: URLResponse?, error: Error?, promise: HiveAPIPromise<Result>) {
		guard error == nil else {
			promise(.failure(.networkingError(error!)))
			return
		}

		guard let response = response as? HTTPURLResponse else {
			promise(.failure(.invalidResponse))
			return
		}

		guard (200..<400).contains(response.statusCode) else {
			promise(.failure(.invalidHTTPResponse(response.statusCode)))
			return
		}

		let decoder = JSONDecoder()
		guard let data = data, let result = try? decoder.decode(Result.self, from: data) else {
			promise(.failure(.invalidData))
			return
		}

		promise(.success(result))
	}

	private func handleVoidResponse(data: Data?, response: URLResponse?, error: Error?, promise: HiveAPIPromise<Bool>) {
		guard error == nil else {
			promise(.failure(.networkingError(error!)))
			return
		}

		guard let response = response as? HTTPURLResponse else {
			promise(.failure(.invalidResponse))
			return
		}

		guard (200..<400).contains(response.statusCode) else {
			promise(.failure(.invalidHTTPResponse(response.statusCode)))
			return
		}

		promise(.success(true))
	}
}
