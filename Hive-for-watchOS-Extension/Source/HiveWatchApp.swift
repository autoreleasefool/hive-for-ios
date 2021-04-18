//
//  HiveWatchApp.swift
//  Hive-for-watchOS-Extension
//
//  Created by Joseph Roque on 2021-04-17.
//  Copyright © 2021 Joseph Roque. All rights reserved.
//

import SwiftUI

@main
struct HiveWatchApp: App {
	var body: some Scene {
		WindowGroup {
			NavigationView {
				ContentView()
					.inject(WatchContainer(watchState: Store(WatchState())))
			}
		}
	}
}
