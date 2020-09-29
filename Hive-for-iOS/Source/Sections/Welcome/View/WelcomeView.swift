//
//  Welcome.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
	@Environment(\.container) private var container
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
				.foregroundColor(Color(.highlightPrimary))

			Button("Play") {
				self.showWelcome = false
			}
			.subtitle()
			.foregroundColor(Color(.textRegular))
			.padding(.m)

			if container.has(feature: .offlineMode) {
				Button("Play offline") {
					self.playingOffline = true
					self.showWelcome = false
				}
				.subtitle()
				.foregroundColor(Color(.textRegular))
				.padding(.m)
			}

			Button("Settings") {
				self.showSettings = true
			}
			.subtitle()
			.foregroundColor(Color(.textRegular))
			.padding(.m)

			Spacer()
		}
		.navigationBarTitle("")
		.navigationBarHidden(true)
	}
}

struct WelcomeViewPreview: PreviewProvider {
	static var previews: some View {
		WelcomeView(
			showWelcome: .constant(true),
			playingOffline: .constant(false),
			showSettings: .constant(true)
		)
	}
}
