//
//  RootTabView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct RootTabView: View {
	@Environment(\.container) private var container

	var body: some View {
		BetterTabView(
			Tab.allCases
				.filter { $0.isEnabled(features: container.features) }
				.map {
					BetterTabView.Tab(
						view: $0.view,
						title: $0.title,
						image: $0.imageName,
						selectedImage: $0.selectedImageName
					)
				}
		)
	}
}

// MARK: - Tabs

extension RootTabView {
	enum Tab: CaseIterable {
		case lobby
		case spectate
		case matchHistory
		case profile

		var title: String {
			switch self {
			case .lobby: return "Lobby"
			case .spectate: return "Spectate"
			case .matchHistory: return "History"
			case .profile: return "Profile"
			}
		}

		var imageName: String {
			switch self {
			case .lobby: return "gamecontroller"
			case .spectate: return "eye"
			case .matchHistory: return "clock"
			case .profile: return "person"
			}
		}

		var selectedImageName: String {
			return "\(imageName).fill"
		}

		@ViewBuilder
		var view: some View {
			switch self {
			case .lobby: LobbyList()
			case .spectate: SpectatorLobbyList()
			case .matchHistory: MatchHistoryList()
			case .profile: ProfileView()
			}
		}

		func isEnabled(features: Features) -> Bool {
			switch self {
			case .lobby: return true
			case .spectate: return features.has(.spectating)
			case .matchHistory: return features.has(.matchHistory)
			case .profile: return features.has(.userProfile)
			}
		}
	}
}

// MARK: - Preview

#if DEBUG
struct RootTabViewPreview: PreviewProvider {
	static var previews: some View {
		RootTabView()
	}
}
#endif
