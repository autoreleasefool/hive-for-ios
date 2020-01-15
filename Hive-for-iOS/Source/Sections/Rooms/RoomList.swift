//
//  RoomList.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct RoomList: View {
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
		List(Room.roomPreviews) { room in
			RoomRow(room: room)
		}
		.listRowInsets(EdgeInsets(equalTo: Metrics.Spacing.standard))
		.navigationBarTitle(Text("Lobby"))
		.navigationBarItems(trailing: newRoomButton)
	}
}

#if DEBUG
struct RoomList_Previews: PreviewProvider {
	static var previews: some View {
		RoomList()
	}
}
#endif
