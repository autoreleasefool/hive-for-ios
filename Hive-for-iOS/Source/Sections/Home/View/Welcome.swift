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

	var body: some View {
		VStack {
			HStack {
				Spacer()
			}
			Spacer()

			Image(uiImage: ImageAsset.glyph)
				.foregroundColor(Color(ColorAsset.primary))

			Button("Play") {
				self.showWelcome = false
			}
			.subtitle()
			.foregroundColor(Color(ColorAsset.text))
			.padding(.m)

			Button("Settings") {
				self.showWelcome = false
			}
			.subtitle()
			.foregroundColor(Color(ColorAsset.text))
			.padding(.m)

			Spacer()
		}
		.navigationBarTitle("")
		.navigationBarHidden(true)
	}
}
