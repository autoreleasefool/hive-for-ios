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
		NavigationLink(
			destination: RoomList()
		) {
			Image(systemName: "plus")
				.imageScale(.large)
				.accessibility(label: Text("Create Room"))
				.padding()
		}
	}

	var body: some View {
		List {
			ForEach(self.viewModel.rooms) { room in
				NavigationLink(
					destination: RoomDetail(roomId: room.id)
				) {
					RoomRow(room: room)
				}
			}
		}
		.listRowInsets(EdgeInsets(equalTo: Metrics.Spacing.standard))
		.navigationBarTitle(Text("Lobby"))
		.navigationBarItems(trailing: newRoomButton)
		.onAppear { self.viewModel.fetchRooms() }
	}
}

#if DEBUG
struct RoomList_Previews: PreviewProvider {
	static var previews: some View {
		RoomList()
	}
}
#endif
