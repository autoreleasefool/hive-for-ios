//
//  AppState.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveFoundation

struct AppState: Equatable {
	var account: Loadable<AnyAccount> = .notLoaded
	var gameSetup: Game.Setup?

	var contentSheetNavigation: ContentView.SheetNavigation?
	var preferences = Preferences()
	var features = Features()
}
