//
//  RootTabView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct RootTabView: View {
	enum Tab: Int {
		case lobby = 0
//		case matchHistory = 1
		case profile = 1

		private var tabImageName: String {
			switch self {
			case .lobby: return "gamecontroller"
//			case .matchHistory: return ""
			case .profile: return "person"
			}
		}

		func tabItem(isSelected: Bool) -> some View {
			Image(systemName: isSelected ? "\(tabImageName).fill" : tabImageName)
		}
	}

	@State private var currentTab = 0

	var body: some View {
		TabView(selection: $currentTab) {
			LobbyV2()
				.tabItem {
					Tab.lobby.tabItem(isSelected: currentTab == Tab.lobby.rawValue)
				}
			Profile()
				.tabItem {
					Tab.profile.tabItem(isSelected: currentTab == Tab.profile.rawValue)
				}
		}
	}
}
