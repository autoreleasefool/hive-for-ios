//
//  RoomDetailView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct RoomDetail: View {
	@ObservedObject var viewModel: RoomDetailViewModel

	init(roomId: String) {
		self.viewModel = RoomDetailViewModel(roomId: roomId)
	}

	var body: some View {
		ZStack {
			Text("Cool")
		}
		.onAppear { self.viewModel.fetchRoomDetails() }
	}
}

#if DEBUG
struct RoomDetail_Preview: PreviewProvider {
	static var previews: some View {
		RoomDetail(roomId: Room.rooms[0].id)
	}
}
#endif
