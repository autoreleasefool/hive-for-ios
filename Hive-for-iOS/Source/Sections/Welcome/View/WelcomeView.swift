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
			Spacer()

			Image(uiImage: ImageAsset.glyph)
				.foregroundColor(Color(.highlightPrimary))

			PrimaryButton("Play") {
				showWelcome = false
			}
			.buttonBackground(.backgroundLight)
			.padding(.horizontal)
			.padding(.bottom)

			if container.has(feature: .offlineMode) {
				PrimaryButton("Play offline") {
					playingOffline = true
					showWelcome = false
				}
				.buttonBackground(.backgroundLight)
				.padding(.horizontal)
				.padding(.bottom)
			}

			PrimaryButton("Settings") {
				showSettings = true
			}
			.buttonBackground(.backgroundLight)
			.padding(.horizontal)

			Spacer()
		}
		.navigationBarTitle("")
		.navigationBarHidden(true)
	}
}

#if DEBUG
struct WelcomeViewPreview: PreviewProvider {
	static var previews: some View {
		WelcomeView(
			showWelcome: .constant(true),
			playingOffline: .constant(false),
			showSettings: .constant(true)
		)
		.background(Color(.backgroundRegular).edgesIgnoringSafeArea(.all))
	}
}
#endif
