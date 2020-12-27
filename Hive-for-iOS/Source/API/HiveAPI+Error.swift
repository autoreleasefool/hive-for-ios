//
//  HiveAPI+Error.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-12-27.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

enum HiveAPIError: LocalizedError {
	case invalidURL
	case networkingError(Error)
	case invalidResponse
	case invalidHTTPResponse(Int, message: String?)
	case invalidData
	case missingData
	case notImplemented
	case unauthorized
	case unsupported
	case usingOfflineAccount

	var errorDescription: String? {
		switch self {
		case .networkingError(let error):
			return "Network error (\(error.localizedDescription))"
		case .invalidResponse, .invalidData:
			return "Could not parse response"
		case .unauthorized:
			return "Unauthorized"
		case .unsupported:
			return "App version unsupported"
		case .invalidHTTPResponse(let code, let message):
			if (500..<600).contains(code) {
				return message == nil
					? "Server error (\(code))"
					: "\(message!) (\(code))"
			} else {
				return message == nil
					? "Unexpected HTTP error (\(code))"
					: "\(message!) (\(code))"
			}
		case .invalidURL:
			return "Failed to form URL"
		case .missingData:
			return "Could not find data"
		case .notImplemented:
			return "The method has not been implemented"
		case .usingOfflineAccount:
			return "Currently offline"
		}
	}

	var formError: String {
		switch self {
		case .usingOfflineAccount:
			return "You've chosen to play offline"
		case .unauthorized:
			return "You entered an incorrect email or password."
		case .networkingError:
			return "There was an error connecting to the server. Are you connected to the Internet?"
		case
			.invalidData,
			.invalidResponse,
			.invalidHTTPResponse,
			.missingData,
			.notImplemented,
			.invalidURL,
			.unsupported:
			return errorDescription ?? localizedDescription
		}
	}

	var loaf: LoafState {
		LoafState(errorDescription ?? "Unknown (API Error)", style: .error())
	}
}

extension HiveAPI {
	struct ErrorBody: Decodable {
		let error: Bool
		let reason: String
	}
}
