//
//  Welcome.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct Welcome: View {
	@Binding var showWelcome: Bool
	@Binding var playingOffline: Bool
	@Binding var showSettings: Bool

	var body: some View {
		VStack {
			HStack {
				Spacer()
			}
			Spacer()

			Image(uiImage: ImageAsset.glyph)
				.foregroundColor(Color(.primary))

			Button("Play") {
				self.showWelcome = false
			}
			.subtitle()
			.foregroundColor(Color(.text))
			.padding(.m)

			Button("Play offline") {
				self.playingOffline = true
				self.showWelcome = false
			}
			.subtitle()
			.foregroundColor(Color(.text))
			.padding(.m)

			Button("Settings") {
				self.showSettings = true
			}
			.subtitle()
			.foregroundColor(Color(.text))
			.padding(.m)

			Spacer()
		}
		.navigationBarTitle("")
		.navigationBarHidden(true)
	}
}
