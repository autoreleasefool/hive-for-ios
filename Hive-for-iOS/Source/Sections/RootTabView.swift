//
//  RootTabView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct RootTabView: View {
	@State private var currentTab = 0

	var body: some View {
		TabView(selection: $currentTab) {
			Lobby()
				.tabItem {
					Tab.lobby.tabItem
				}
			Profile()
				.tabItem {
					Tab.profile.tabItem
				}
		}
		.accentColor(Color(.primary))
	}
}

// MARK: - Tabs

extension RootTabView {
	enum Tab: Int {
			case lobby = 0
	//		case matchHistory = 1
			case profile = 1

			var tabImageName: String {
				switch self {
				case .lobby: return "gamecontroller.fill"
	//			case .matchHistory: return ""
				case .profile: return "person.fill"
				}
			}

			var tabItem: some View {
				Image(systemName: tabImageName)
			}
		}
}

#if DEBUG
struct RootTabViewPreview: PreviewProvider {
	static var previews: some View {
		RootTabView()
	}
}
#endif
