//
//  AppState.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

struct AppState: Equatable {
	var account: Loadable<Account> = .notLoaded
	var gameSetup: Game.Setup?

	private(set) var contentSheetNavigation: ContentView.SheetNavigation?
	var preferences = Preferences()
	var features = Features()

	mutating func setNavigation(to navigation: ContentView.SheetNavigation?) {
		guard contentSheetNavigation == nil else { return }
		contentSheetNavigation = navigation
	}

	mutating func clearNavigation(of navigation: ContentView.SheetNavigation?) {
		guard contentSheetNavigation == navigation else { return }
		contentSheetNavigation = nil
	}
}
