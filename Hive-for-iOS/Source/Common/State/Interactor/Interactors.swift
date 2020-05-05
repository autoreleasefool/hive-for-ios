//
//  Interactors.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

extension AppContainer {
	struct Interactors {
		let accountInteractor: AccountInteractor
		let matchInteractor: MatchInteractor

		static var stub: Interactors {
			Interactors(
				accountInteractor: StubAccountInteractor(),
				matchInteractor: StubMatchInteractor()
			)
		}
	}
}
