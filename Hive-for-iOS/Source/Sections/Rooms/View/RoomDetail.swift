//
//  RoomDetailView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct RoomDetail: View {
	@ObservedObject private var viewModel: RoomDetailViewModel
	@State private var inGame = false

	init(viewModel: RoomDetailViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		return List {
			if viewModel.room == nil {
				Text("Loading")
			} else {
				Text(viewModel.room!.host.name)
				ForEach(GameState.Options.allCases, id: \.rawValue) { option in
					Toggle(option.rawValue, isOn: self.viewModel.options.binding(for: option))
				}
				NavigationLink(
					destination: GameContainer(isActive: self.$inGame, state: self.viewModel.gameState),
					isActive: self.$inGame
				) {
					Text("Start")
				}
			}
		}
		.navigationBarTitle(Text("Room \(viewModel.roomId)"), displayMode: .inline)
		.onAppear { self.viewModel.postViewAction(.onAppear) }
		.onDisappear { self.viewModel.postViewAction(.onDisappear) }
		.loaf(self.$viewModel.errorLoaf)
	}
}

#if DEBUG
struct RoomDetailPreview: PreviewProvider {
	static var previews: some View {
		RoomDetail(viewModel: RoomDetailViewModel(roomId: Room.rooms[0].id))
	}
}
#endif
