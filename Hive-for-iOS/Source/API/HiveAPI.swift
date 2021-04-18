//
//  HiveAPI.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation
import HiveFoundation
import Loaf

typealias HiveAPIPromise<Success> = Future<Success, HiveAPIError>.Promise

class HiveAPI: NSObject, ObservableObject, URLSessionTaskDelegate {
	static let baseURL: URL = {
		#if DEBUG
		let debugURL = URL(string: "https://hiveapi.josephroque.dev")!
		return debugURL
		#else
		let releaseURL = URL(string: "https://hiveapi.josephroque.dev")!
		return releaseURL
		#endif
	}()

	private var session: URLSession!
	private let requestQueue: DispatchQueue
	private let operationQueue = OperationQueue()

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

	init(
		configuration: URLSessionConfiguration = .default,
		queue: DispatchQueue = DispatchQueue(label: "ca.josephroque.hiveapp.api.requestQueue")
	) {
		self.requestQueue = queue
		self.operationQueue.underlyingQueue = requestQueue
		super.init()
		self.session = URLSession(
			configuration: configuration,
			delegate: self,
			delegateQueue: operationQueue
		)
	}

	func fetch<Output: Decodable>(
		_ endpoint: Endpoint,
		withAccount account: Account? = nil
	) -> AnyPublisher<Output, HiveAPIError> {
		guard account?.isOffline != true else {
			return Fail(error: .usingOfflineAccount).eraseToAnyPublisher()
		}

		var components = URLComponents(
			url: HiveAPI.baseURL
				.appendingPathComponent("api")
				.appendingPathComponent(endpoint.path),
			resolvingAgainstBaseURL: true
		)

		if let queryParams = endpoint.queryParams {
			components?.queryItems = queryParams.map {
				URLQueryItem(name: $0.key, value: $0.value)
			}
		}

		guard let url = components?.url else {
			return Fail(error: .invalidURL)
				.eraseToAnyPublisher()
		}

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
			.subscribe(on: requestQueue)
			.tryMap { data, response in
				guard let httpResponse = response as? HTTPURLResponse else {
					logger.error("Invalid response from \(endpoint)")
					throw HiveAPIError.invalidResponse
				}

				guard (200..<400).contains(httpResponse.statusCode) else {
					guard let body = try? JSONDecoder().decode(ErrorBody.self, from: data) else {
						logger.error("Invalid status (\(httpResponse.statusCode)) from \(endpoint)")
						throw HiveAPIError.invalidHTTPResponse(httpResponse.statusCode, message: nil)
					}

					logger.error("Invalid status (\(httpResponse.statusCode)) from \(endpoint) (\(body.reason))")
					throw HiveAPIError.invalidHTTPResponse(httpResponse.statusCode, message: body.reason)
				}

				return data
			}
			.decode(type: Output.self, decoder: decoder)
			.mapError {
				logger.error("Error from \(endpoint), error: \($0)")
				if let apiError = $0 as? HiveAPIError {
					if case .invalidHTTPResponse(let statusCode, _) = apiError {
						if statusCode == 401 {
							self.reportUnauthorizedRequest()
							return .unauthorized
						} else if statusCode == 418 {
							self.reportUnsupportedVersion()
							return .unsupported
						}
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
		case .signInWithApple(let data):
			return try encoder.encode(data)
		case .updateAccount(let data):
			return try encoder.encode(data)
		case
			.createGuestAccount,
			.openMatches,
			.activeMatches,
			.checkToken,
			.logout,
			.userDetails,
			.matchDetails,
			.joinMatch,
			.createMatch,
			.filterUsers:
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

	private func reportUnsupportedVersion() {
		NotificationCenter.default.post(name: NSNotification.Name.AppInfo.Unsupported, object: nil)
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
