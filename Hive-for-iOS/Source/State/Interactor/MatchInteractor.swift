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
	func loadOpenMatches(withAccount account: AccountV2?, matches: LoadableSubject<[Match]>)
	func loadMatchDetails(id: Match.ID, withAccount account: AccountV2?, match: LoadableSubject<Match>)
	func joinMatch(id: Match.ID, withAccount account: AccountV2?, match: LoadableSubject<Match>)
	func createNewMatch(withAccount account: AccountV2?, match: LoadableSubject<Match>)
}

struct LiveMatchInteractor: MatchInteractor {
	let repository: MatchRepository

	func loadOpenMatches(withAccount account: AccountV2?, matches: LoadableSubject<[Match]>) {
		let cancelBag = CancelBag()
		matches.wrappedValue = .loading(cached: matches.wrappedValue.value, cancelBag: cancelBag)

		repository.loadOpenMatches(withAccount: account)
			.receive(on: DispatchQueue.main)
			.sinkToLoadable { matches.wrappedValue = $0 }
			.store(in: cancelBag)
	}

	func loadMatchDetails(id: Match.ID, withAccount account: AccountV2?, match: LoadableSubject<Match>) {
		let cancelBag = CancelBag()
		match.wrappedValue = .loading(cached: match.wrappedValue.value, cancelBag: cancelBag)

		repository.loadMatchDetails(id: id, withAccount: account)
			.receive(on: DispatchQueue.main)
			.sinkToLoadable { match.wrappedValue = $0 }
			.store(in: cancelBag)
	}

	func joinMatch(id: Match.ID, withAccount account: AccountV2?, match: LoadableSubject<Match>) {
		let cancelBag = CancelBag()
		match.wrappedValue = .loading(cached: match.wrappedValue.value, cancelBag: cancelBag)

		repository.joinMatch(id: id, withAccount: account)
			.receive(on: DispatchQueue.main)
			.sinkToLoadable { match.wrappedValue = $0 }
			.store(in: cancelBag)
	}

	func createNewMatch(withAccount account: AccountV2?, match: LoadableSubject<Match>) {
		let cancelBag = CancelBag()
		match.wrappedValue = .loading(cached: match.wrappedValue.value, cancelBag: cancelBag)

		repository.createNewMatch(withAccount: account)
			.receive(on: DispatchQueue.main)
			.sinkToLoadable { match.wrappedValue = $0 }
			.store(in: cancelBag)
	}
}

struct StubMatchInteractor: MatchInteractor {
	func loadOpenMatches(withAccount account: AccountV2?, matches: LoadableSubject<[Match]>) { }
	func loadMatchDetails(id: Match.ID, withAccount account: AccountV2?, match: LoadableSubject<Match>) { }
	func joinMatch(id: Match.ID, withAccount account: AccountV2?, match: LoadableSubject<Match>) { }
	func createNewMatch(withAccount account: AccountV2?, match: LoadableSubject<Match>) { }
}
