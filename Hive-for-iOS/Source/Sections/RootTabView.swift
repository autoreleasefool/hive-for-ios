//
//  RootTabView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct RootTabView: View {
	var body: some View {
		BetterTabView(
			Tab.allCases.map {
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
		case matchHistory
		case profile

		var title: String {
			switch self {
			case .lobby: return "Lobby"
			case .matchHistory: return "History"
			case .profile: return "Profile"
			}
		}

		var imageName: String {
			switch self {
			case .lobby: return "gamecontroller"
			case .matchHistory: return "clock"
			case .profile: return "person"
			}
		}

		var selectedImageName: String {
			return "\(imageName).fill"
		}

		var view: AnyView {
			switch self {
			case .lobby: return AnyView(Lobby())
			case .matchHistory: return AnyView(History())
			case .profile: return AnyView(Profile())
			}
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
