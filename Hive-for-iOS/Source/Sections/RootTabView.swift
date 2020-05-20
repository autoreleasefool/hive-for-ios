//
//  RootTabView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct RootTabView: View {
	@Environment(\.container) private var container: AppContainer
	@State private var selectedTab = 0

	var body: some View {
		TabView(selection: $selectedTab) {
			Lobby()
				.tabItem { Tab.lobby.tabItem }
				.tag(0)
			History()
				.tabItem { Tab.matchHistory.tabItem }
				.tag(1)
			Profile()
				.tabItem { Tab.profile.tabItem }
				.tag(2)
		}
		.accentColor(Color(.primary))
	}
}

// MARK: - Tabs

extension RootTabView {
	enum Tab {
		case lobby
		case matchHistory
		case profile

		var tabImageName: String {
			switch self {
			case .lobby: return "gamecontroller.fill"
			case .matchHistory: return "clock.fill"
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
