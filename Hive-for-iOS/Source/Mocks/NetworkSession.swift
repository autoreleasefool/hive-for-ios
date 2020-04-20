//
//  NetworkSession.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-18.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import Regex

protocol NetworkSession {
	func loadData(from request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: NetworkSession {
	func loadData(from request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
		dataTask(with: request, completionHandler: completionHandler).resume()
	}
}

#if DEBUG
class MockURLSession: NetworkSession {
	private var mocks: [MockableRequest: [Data]] = [:]
	private let encoder: JSONEncoder = {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		return encoder
	}()

	func mock<Object: Codable>(_ request: MockableRequest, with object: Object) {
		guard let data = try? encoder.encode(object) else { return }
		mocks[request] = [data]
	}

	func appendMock<Object: Codable>(object: Object, to request: MockableRequest) {
		guard let data = try? encoder.encode(object) else { return }

		if var mocks = self.mocks[request] {
			mocks.append(data)
			self.mocks[request] = mocks
		} else {
			mocks[request] = [data]
		}
	}

	func clearMock(_ request: MockableRequest) {
		mocks[request] = nil
	}

	func clearMocks() {
		mocks.removeAll()
	}

	private func dropFirstMock(from request: MockableRequest) {
		if let mocks = self.mocks[request] {
			self.mocks[request] = Array(mocks.dropFirst())
		}
	}

	func loadData(from request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
		guard let mockable = mockableRequest(from: request) else {
			return completionHandler(nil, nil, nil)
		}

		if let mocks = self.mocks[mockable], let mock = mocks.first {
			let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
			dropFirstMock(from: mockable)
			completionHandler(mock, response, nil)
		} else {
			completionHandler(nil, nil, nil)
		}
	}

	private func mockableRequest(from request: URLRequest) -> MockableRequest? {
		guard let string = request.url?.absoluteString else { return nil }
		if string.contains("match") && string.hasSuffix("open") {
			return .openMatches
		} else if string.contains("match") && string.hasSuffix("new") {
			return .createMatch
		} else if string.contains("match") && string.hasSuffix("join") {

		}

		return nil
	}

	enum MockableRequest: Hashable {
		case openMatches
		case matchDetails(Match.ID)
		case joinMatch(Match.ID)
		case createMatch

		private static let matchEndpoint = Regex(#"/api/matches"#)
		private static let matchId = Regex(
			#"/api/matches/([0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})"#
		)

		init?(from: URLRequest) {
			guard let string = from.url?.absoluteString else { return nil }
			if MockableRequest.matchEndpoint.matches(string) {
				if string.hasSuffix("open") {
					self = .openMatches
				} else if string.hasSuffix("new") {
					self = .createMatch
				} else if string.hasSuffix("join"), let id = MockableRequest.matchId.firstMatch(in: string) {
					self = .joinMatch(UUID(uuidString: id.captures[0]!)!)
				} else if let id = MockableRequest.matchId.firstMatch(in: string) {
					self = .matchDetails(UUID(uuidString: id.captures[0]!)!)
				} else {
					return nil
				}
			} else {
				return nil
			}
		}
	}
}
#endif
