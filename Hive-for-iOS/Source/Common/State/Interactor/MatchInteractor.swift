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
	func loadActiveMatches(matches: LoadableSubject<[Match]>)

	func loadMatchDetails(id: Match.ID, match: LoadableSubject<Match>)
	func joinMatch(id: Match.ID, match: LoadableSubject<Match>)
	func createNewMatch(match: LoadableSubject<Match>)
}

struct LiveMatchInteractor: MatchInteractor {
	let repository: MatchRepository
	let appState: Store<AppState>

	func loadOpenMatches(matches: LoadableSubject<[Match]>) {
		let cancelBag = CancelBag()
		matches.wrappedValue.setLoading(cancelBag: cancelBag)

		repository.loadOpenMatches(withAccount: appState.value.account.value)
			.receive(on: RunLoop.main)
			.sinkToLoadable { matches.wrappedValue = $0 }
			.store(in: cancelBag)
	}

	func loadActiveMatches(matches: LoadableSubject<[Match]>) {
		let cancelBag = CancelBag()
		matches.wrappedValue.setLoading(cancelBag: cancelBag)

		repository.loadActiveMatches(withAccount: appState.value.account.value)
			.receive(on: RunLoop.main)
			.sinkToLoadable { matches.wrappedValue = $0 }
			.store(in: cancelBag)
	}

	func loadMatchDetails(id: Match.ID, match: LoadableSubject<Match>) {
		let cancelBag = CancelBag()
		match.wrappedValue.setLoading(cancelBag: cancelBag)

		repository.loadMatchDetails(id: id, withAccount: appState.value.account.value)
			.receive(on: RunLoop.main)
			.sinkToLoadable { match.wrappedValue = $0 }
			.store(in: cancelBag)
	}

	func joinMatch(id: Match.ID, match: LoadableSubject<Match>) {
		let cancelBag = CancelBag()
		match.wrappedValue.setLoading(cancelBag: cancelBag)

		repository.joinMatch(id: id, withAccount: appState.value.account.value)
			.receive(on: RunLoop.main)
			.sinkToLoadable { match.wrappedValue = $0 }
			.store(in: cancelBag)
	}

	func createNewMatch(match: LoadableSubject<Match>) {
		let cancelBag = CancelBag()
		match.wrappedValue.setLoading(cancelBag: cancelBag)

		repository.createNewMatch(withAccount: appState.value.account.value)
			.receive(on: RunLoop.main)
			.sinkToLoadable { match.wrappedValue = $0 }
			.store(in: cancelBag)
	}
}

struct StubMatchInteractor: MatchInteractor {
	func loadOpenMatches(matches: LoadableSubject<[Match]>) { }
	func loadActiveMatches(matches: LoadableSubject<[Match]>) { }
	func loadMatchDetails(id: Match.ID, match: LoadableSubject<Match>) { }
	func joinMatch(id: Match.ID, match: LoadableSubject<Match>) { }
	func createNewMatch(match: LoadableSubject<Match>) { }
}
