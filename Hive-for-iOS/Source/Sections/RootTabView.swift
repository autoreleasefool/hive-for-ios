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
	private var profileViewModel = ProfileViewModel(userId: UUID())

	var body: some View {
		TabView(selection: $currentTab) {
			Lobby()
				.tabItem {
					Tab.lobby.tabItem(isSelected: currentTab == Tab.lobby.rawValue)
				}
			Profile(viewModel: profileViewModel)
				.tabItem {
					Tab.profile.tabItem(isSelected: currentTab == Tab.profile.rawValue)
				}
		}
	}
}