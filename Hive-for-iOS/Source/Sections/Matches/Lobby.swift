//
//  Lobby.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct Lobby: View {
	@EnvironmentObject private var api: HiveAPI
	@ObservedObject private var viewModel = LobbyViewModel()

	var newMatchButton: some View {
		NavigationLink(destination: MatchDetail(id: nil, client: self.viewModel.client)) {
			Image(systemName: "plus")
				.imageScale(.large)
				.accessibility(label: Text("Create Match"))
				.padding(.all, length: .m)
		}
	}

	var body: some View {
		List(self.viewModel.matches) { match in
			NavigationLink(destination: MatchDetail(id: match.id, client: self.viewModel.client)) {
				MatchRow(match: match)
			}
		}
		.listRowInsets(EdgeInsets(equalTo: .m))
		.onAppear {
			self.viewModel.setAPI(to: self.api)
			self.viewModel.postViewAction(.onAppear)
		}
		.onDisappear { self.viewModel.postViewAction(.onDisappear) }
		.navigationBarTitle(Text("Lobby"))
		.navigationBarItems(trailing: newMatchButton)
	}
}

#if DEBUG
struct LobbyPreview: PreviewProvider {
	static var previews: some View {
		Lobby()
	}
}
#endif
