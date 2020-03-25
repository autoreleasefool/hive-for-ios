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

	init(viewModel: RoomDetailViewModel) {
		self.viewModel = viewModel
	}

	var startButton: some View {
		NavigationLink(destination: HiveGame(state: self.viewModel.gameState)) {
			Text("Start")
		}
	}

	private func playerSection(room: Room) -> some View {
		HStack(spacing: 0) {
			Spacer()
			PlayerPreview(room.host, iconSize: .l)
			Spacer()
			PlayerPreview(room.host, alignment: .trailing, iconSize: .l)
			Spacer()
		}
	}

	private func expansionSection(options: GameOptionData) -> some View {
		VStack(alignment: .leading) {
			Text("Expansions")
				.subtitle()
				.foregroundColor(Color(ColorAsset.text))
			ForEach(GameState.Option.expansions, id: \.rawValue) { option in
				Toggle(option.rawValue, isOn: self.viewModel.options.binding(for: option))
					.foregroundColor(Color(ColorAsset.text))
			}
		}
	}

	private func otherOptionsSection(options: GameOptionData) -> some View {
		VStack(alignment: .leading) {
			Text("Other options")
				.subtitle()
				.foregroundColor(Color(ColorAsset.text))
			ForEach(GameState.Option.nonExpansions, id: \.rawValue) { option in
				Toggle(option.rawValue, isOn: self.viewModel.options.binding(for: option))
					.foregroundColor(Color(ColorAsset.text))
			}
		}
	}

	var body: some View {
		List {
			if self.viewModel.room == nil {
				Text("Loading")
			} else {
				self.playerSection(room: self.viewModel.room!)
					.padding(.vertical, length: .m)
				self.expansionSection(options: self.viewModel.options)
				self.otherOptionsSection(options: self.viewModel.options)
			}
		}
		.navigationBarTitle(Text("Room \(viewModel.roomId)"), displayMode: .inline)
		.navigationBarItems(trailing: startButton)
		.onAppear { self.viewModel.postViewAction(.onAppear) }
		.onDisappear { self.viewModel.postViewAction(.onDisappear) }
		.loaf(self.$viewModel.errorLoaf)
	}
}

private extension GameState.Option {
	var preview: String? {
		switch self {
		case .mosquito: return "M"
		case .ladyBug: return "L"
		case .pillBug: return "P"
		default: return nil
		}
	}
}

#if DEBUG
struct RoomDetailPreview: PreviewProvider {
	static var previews: some View {
		RoomDetail(viewModel: RoomDetailViewModel(room: Room.rooms[0]))
	}
}
#endif
