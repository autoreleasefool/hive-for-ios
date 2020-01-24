//
//  RoomList.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct RoomList: View {
	@ObservedObject private var viewModel = RoomListViewModel()

	var newRoomButton: some View {
		NavigationLink(destination: RoomList()) {
			Image(systemName: "plus")
				.imageScale(.large)
				.accessibility(label: Text("Create Room"))
				.padding()
		}
	}

	var body: some View {
		NavigationView {
			List(self.viewModel.rooms) { room in
				NavigationLink(destination: RoomDetail(viewModel: self.viewModel.roomViewModels[room.id]!)) {
					RoomRow(room: room)
				}
			}
			.listRowInsets(EdgeInsets(equalTo: Metrics.Spacing.standard))
			.onAppear { self.viewModel.postViewAction(.onAppear) }
			.onDisappear { self.viewModel.postViewAction(.onDisappear) }
	//		.loaf(self.$viewModel.errorLoaf)

			.navigationBarTitle(Text("Lobby"))
			.navigationBarItems(trailing: newRoomButton)
		}

	}
}

#if DEBUG
struct RoomList_Previews: PreviewProvider {
	static var previews: some View {
		RoomList()
	}
}
#endif
