//
//  AppState.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

struct AppState: Equatable {
	var account: Loadable<Account> = .notLoaded
	var userProfile: Loadable<User> = .notLoaded

	var preferences = Preferences()
	var routing = Routing()
}
