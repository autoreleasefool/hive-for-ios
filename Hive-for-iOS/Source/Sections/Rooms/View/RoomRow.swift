//
//  RoomView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct RoomRow: View {
	let room: Room

	var body: some View {
		HStack {
			RemoteImage(
				url: room.host.avatarUrl,
				placeholder: Assets.Image.glyph
			)
				.scaledToFit()
				.frame(width: Metrics.Image.listIcon, height: Metrics.Image.listIcon)
			VStack {
				Text(room.host.name)
				if room.opponent != nil {
					Text(room.opponent!.name)
				}
			}
			Text(room.host.formattedELO)
		}
		.padding(EdgeInsets(equalTo: Metrics.Spacing.standard))
	}
}

#if DEBUG
struct RoomRow_Previews: PreviewProvider {
	static var previews: some View {
		RoomRow(room: Room.rooms[0])
	}
}
#endif
