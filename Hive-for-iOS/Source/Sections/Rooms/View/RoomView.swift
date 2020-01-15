//
//  RoomView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct RoomView: View {
	let room: Room

	var body: some View {
		HStack {
			RemoteImage(
				url: room.host.avatarUrl,
				placeholder: Assets.Image.glyph
			)
				.scaledToFit()
				.frame(width: Metrics.Image.listIcon, height: Metrics.Image.listIcon)
			Text(room.host.name)
			Text(room.host.formattedELO)
		}
		.padding(EdgeInsets(equalTo: Metrics.Spacing.standard))
	}
}

#if DEBUG
struct RoomView_Previews: PreviewProvider {
	static var previews: some View {
		RoomView(room: Room.rooms[0])
	}
}
#endif
