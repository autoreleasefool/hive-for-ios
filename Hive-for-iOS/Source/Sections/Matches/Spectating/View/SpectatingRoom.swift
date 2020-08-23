//
//  SpectatingRoom.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-08-20.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct SpectatingRoom: View {
	init(id: Match.ID?) {

	}

	var body: some View {
		VStack {
			Spacer()
			HStack {
				Spacer()
				ActivityIndicator(isAnimating: true, style: .whiteLarge)
				Spacer()
			}
			Spacer()
		}
	}
}
