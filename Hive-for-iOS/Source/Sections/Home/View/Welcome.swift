//
//  Welcome.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct Welcome: View {
	@Binding var isPlaying: Bool

	var body: some View {
		VStack {
			HStack {
				Spacer()
			}
			Spacer()

			Image(uiImage: Assets.Image.glyph)
				.foregroundColor(.primary)

			Button("Play") {
				self.isPlaying = true
			}
				.font(.system(size: .subtitle))
				.foregroundColor(.text)
				.padding(EdgeInsets(equalTo: .standard))

			Button("Settings") {
				self.isPlaying = true
			}
				.font(.system(size: .subtitle))
				.foregroundColor(.text)
				.padding(EdgeInsets(equalTo: .standard))

			Spacer()
		}
		.background(.background)
		.edgesIgnoringSafeArea(.all)
	}
}
