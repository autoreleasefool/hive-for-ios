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
		List {
			Text("Room #1")
		}
		.listRowInsets(EdgeInsets())
		.navigationBarTitle(Text("Lobby"))
		.navigationBarItems(trailing: newRoomButton)
	}
}
