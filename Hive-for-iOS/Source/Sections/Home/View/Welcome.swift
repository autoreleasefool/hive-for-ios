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
				.foregroundColor(Assets.Color.primary.color)

			Button("Play") {
				self.isPlaying = true
			}
				.font(.system(size: Metrics.Text.subtitle))
				.foregroundColor(Assets.Color.text.color)
				.padding(EdgeInsets(equalTo: Metrics.Spacing.standard))

			Button("Settings") {
				self.isPlaying = true
			}
				.font(.system(size: Metrics.Text.subtitle))
				.foregroundColor(Assets.Color.text.color)
				.padding(EdgeInsets(equalTo: Metrics.Spacing.standard))

			Spacer()
		}
		.background(Assets.Color.background.color)
		.edgesIgnoringSafeArea(.all)
	}
}
