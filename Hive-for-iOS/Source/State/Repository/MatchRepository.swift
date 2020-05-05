//
//  MatchRepository.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation

enum MatchRepositoryError: Error {
	case apiError(HiveAPIError)
}

protocol MatchRepository {
	func loadOpenMatches(withAccount account: AccountV2?) -> AnyPublisher<[Match], MatchRepositoryError>
	func loadMatchDetails(id: Match.ID, withAccount account: AccountV2?) -> AnyPublisher<Match, MatchRepositoryError>
	func joinMatch(id: Match.ID, withAccount account: AccountV2?) -> AnyPublisher<Match, MatchRepositoryError>
	func createNewMatch(withAccount account: AccountV2?) -> AnyPublisher<Match, MatchRepositoryError>
}

struct LiveMatchRepository: MatchRepository {
	private let api: HiveAPI

	init(api: HiveAPI) {
		self.api = api
	}

	func loadOpenMatches(withAccount account: AccountV2?) -> AnyPublisher<[Match], MatchRepositoryError> {
		api.openMatches(withAccount: account)
			.mapError { .apiError($0) }
			.eraseToAnyPublisher()
	}

	func loadMatchDetails(id: Match.ID, withAccount account: AccountV2?) -> AnyPublisher<Match, MatchRepositoryError> {
		api.matchDetails(id: id, withAccount: account)
			.mapError { .apiError($0) }
			.eraseToAnyPublisher()
	}

	func joinMatch(id: Match.ID, withAccount account: AccountV2?) -> AnyPublisher<Match, MatchRepositoryError> {
		api.joinMatch(id: id, withAccount: account)
			.mapError { .apiError($0) }
			.eraseToAnyPublisher()
	}

	func createNewMatch(withAccount account: AccountV2?) -> AnyPublisher<Match, MatchRepositoryError> {
		api.createMatch(withAccount: account)
			.mapError { .apiError($0) }
			.eraseToAnyPublisher()
	}
}
