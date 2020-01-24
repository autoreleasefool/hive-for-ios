//
//  Home.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct Home: View {
	@State var isPlaying: Bool = false

	var body: some View {
		Group {
			if isPlaying {
				RoomList()
			} else {
				Welcome(isPlaying: $isPlaying)
			}
		}
	}
}

#if DEBUG
struct HomePreview: PreviewProvider {
	static var previews: some View {
		Home()
	}
}
#endif
