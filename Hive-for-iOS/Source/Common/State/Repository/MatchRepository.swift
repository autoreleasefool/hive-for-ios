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
	case usingOfflineAccount
	case apiError(HiveAPIError)
}

protocol MatchRepository {
	func loadOpenMatches(withAccount account: Account?) -> AnyPublisher<[Match], MatchRepositoryError>
	func loadMatchDetails(id: Match.ID, withAccount account: Account?) -> AnyPublisher<Match, MatchRepositoryError>
	func joinMatch(id: Match.ID, withAccount account: Account?) -> AnyPublisher<Match, MatchRepositoryError>
	func createNewMatch(withAccount account: Account?) -> AnyPublisher<Match, MatchRepositoryError>
}

struct LiveMatchRepository: MatchRepository {
	private let api: HiveAPI

	init(api: HiveAPI) {
		self.api = api
	}

	func loadOpenMatches(withAccount account: Account?) -> AnyPublisher<[Match], MatchRepositoryError> {
		guard account?.isOffline != true else {
			return Fail(error: .usingOfflineAccount).eraseToAnyPublisher()
		}

		return api.fetch(.openMatches, withAccount: account)
			.mapError { .apiError($0) }
			.eraseToAnyPublisher()
	}

	func loadMatchDetails(id: Match.ID, withAccount account: Account?) -> AnyPublisher<Match, MatchRepositoryError> {
		guard account?.isOffline != true else {
			return Fail(error: .usingOfflineAccount).eraseToAnyPublisher()
		}

		return api.fetch(.matchDetails(id), withAccount: account)
			.mapError { .apiError($0) }
			.eraseToAnyPublisher()
	}

	func joinMatch(id: Match.ID, withAccount account: Account?) -> AnyPublisher<Match, MatchRepositoryError> {
		guard account?.isOffline != true else {
			return Fail(error: .usingOfflineAccount).eraseToAnyPublisher()
		}

		return api.fetch(.joinMatch(id), withAccount: account)
			.mapError { .apiError($0) }
			.eraseToAnyPublisher()
	}

	func createNewMatch(withAccount account: Account?) -> AnyPublisher<Match, MatchRepositoryError> {
		guard account?.isOffline != true else {
			return Fail(error: .usingOfflineAccount).eraseToAnyPublisher()
		}

		return api.fetch(.createMatch, withAccount: account)
			.mapError { .apiError($0) }
			.eraseToAnyPublisher()
	}
}
