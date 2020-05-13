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
		TabView(selection: presentedTab) {
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

	var presentedTab: Binding<Int> {
		Binding(
			get: { self.selectedTab },
			set: { newValue in
				guard !self.container.appState.value.routing.lobbyRouting.inRoom else { return }
				self.selectedTab = newValue
			}
		)
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
