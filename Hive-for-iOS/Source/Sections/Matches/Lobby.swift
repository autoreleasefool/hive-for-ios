//
//  Lobby.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import SwiftUIRefresh

struct Lobby: View {
	@Environment(\.toaster) private var toaster: Toaster
	@EnvironmentObject private var api: HiveAPI
	@ObservedObject private var viewModel = LobbyViewModel()

	@State private var refreshing: Bool = false

	var newMatchButton: some View {
		NavigationLink(destination: MatchDetail(viewModel: self.viewModel.newMatchViewModel)) {
			Image(systemName: "plus")
				.imageScale(.large)
				.accessibility(label: Text("Create Match"))
				.padding(.all, length: .m)
		}
	}

	var body: some View {
		List(self.viewModel.matches) { match in
			NavigationLink(destination: MatchDetail(viewModel: self.viewModel.detailViewModels[match.id]!)) {
				MatchRow(match: match)
			}
		}
		.pullToRefresh(isShowing: self.$refreshing) {
			self.viewModel.postViewAction(.refreshMatches)
		}
		.onReceive(self.viewModel.breadBox) { self.toaster.loaf.send($0) }
		.onReceive(self.viewModel.refreshComplete) { _ in self.refreshing = false }
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
		let account = Account()
		let api = HiveAPI(account: account)

		return Lobby().environmentObject(api)
	}
}
#endif
