//
//  Lobby.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct Lobby: View {
	@ObservedObject private var viewModel = LobbyViewModel()

	var newMatchButton: some View {
		NavigationLink(destination: Lobby()) {
			Image(systemName: "plus")
				.imageScale(.large)
				.accessibility(label: Text("Create Match"))
				.padding(.all, length: .m)
		}
	}

	var body: some View {
		NavigationView {
			List(self.viewModel.matches) { match in
				NavigationLink(destination: MatchDetail(viewModel: self.viewModel.matchViewModels[match.id]!)) {
					MatchRow(match: match)
				}
			}
			.listRowInsets(EdgeInsets(equalTo: Metrics.Spacing.m.rawValue))
			.onAppear { self.viewModel.postViewAction(.onAppear) }
			.onDisappear { self.viewModel.postViewAction(.onDisappear) }
	//		.loaf(self.$viewModel.errorLoaf)

			.navigationBarTitle(Text("Lobby"))
			.navigationBarItems(trailing: newMatchButton)
		}
	}
}

#if DEBUG
struct LobbyPreview: PreviewProvider {
	static var previews: some View {
		Lobby()
	}
}
#endif
