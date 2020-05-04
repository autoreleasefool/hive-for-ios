//
//  MatchInteractor.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import Foundation

protocol MatchInteractor {
	func loadOpenMatches(matches: LoadableSubject<[Match]>)
	func loadMatchDetails(id: Match.ID, match: LoadableSubject<Match>)
	func joinMatch(id: Match.ID, match: LoadableSubject<Match>)
	func createNewMatch(match: LoadableSubject<Match>)
}

struct LiveMatchInteractor: MatchInteractor {
	let repository: MatchRepository

	func loadOpenMatches(matches: LoadableSubject<[Match]>) {
		let cancelBag = CancelBag()
		matches.wrappedValue = .loading(cached: matches.wrappedValue.value, cancelBag: cancelBag)

		repository.loadOpenMatches()
			.receive(on: DispatchQueue.main)
			.sinkToLoadable { matches.wrappedValue = $0 }
			.store(in: cancelBag)
	}

	func loadMatchDetails(id: Match.ID, match: LoadableSubject<Match>) {
		let cancelBag = CancelBag()
		match.wrappedValue = .loading(cached: match.wrappedValue.value, cancelBag: cancelBag)

		repository.loadMatchDetails(id: id)
			.receive(on: DispatchQueue.main)
			.sinkToLoadable { match.wrappedValue = $0 }
			.store(in: cancelBag)
	}

	func joinMatch(id: Match.ID, match: LoadableSubject<Match>) {
		let cancelBag = CancelBag()
		match.wrappedValue = .loading(cached: match.wrappedValue.value, cancelBag: cancelBag)

		repository.joinMatch(id: id)
			.receive(on: DispatchQueue.main)
			.sinkToLoadable { match.wrappedValue = $0 }
			.store(in: cancelBag)
	}

	func createNewMatch(match: LoadableSubject<Match>) {
		let cancelBag = CancelBag()
		match.wrappedValue = .loading(cached: match.wrappedValue.value, cancelBag: cancelBag)

		repository.createNewMatch()
			.receive(on: DispatchQueue.main)
			.sinkToLoadable { match.wrappedValue = $0 }
			.store(in: cancelBag)
	}
}

struct StubMatchInteractor: MatchInteractor {
	func loadOpenMatches(matches: LoadableSubject<[Match]>) { }
	func loadMatchDetails(id: Match.ID, match: LoadableSubject<Match>) { }
	func joinMatch(id: Match.ID, match: LoadableSubject<Match>) { }
	func createNewMatch(match: LoadableSubject<Match>) { }
}
