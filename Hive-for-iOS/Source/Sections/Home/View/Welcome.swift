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

			Image(uiImage: ImageAsset.glyph)
				.foregroundColor(Color(ColorAsset.primary))

			Button("Play") {
				self.isPlaying = true
			}
				.font(.system(size: Metrics.Text.subtitle))
				.foregroundColor(Color(ColorAsset.text))
				.padding(Metrics.Spacing.standard)

			Button("Settings") {
				self.isPlaying = true
			}
				.font(.system(size: Metrics.Text.subtitle))
				.foregroundColor(Color(ColorAsset.text))
				.padding(Metrics.Spacing.standard)

			Spacer()
		}
		.background(Color(ColorAsset.background))
		.edgesIgnoringSafeArea(.all)
	}
}
