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

	let onShowSettings: () -> Void
	let onPlayOffline: () -> Void
	@State private var isLoggingIn: Bool = false

	var body: some View {
		VStack {
			Spacer()

			Image(uiImage: ImageAsset.glyph)
				.foregroundColor(Color(.highlightPrimary))

			NavigationLink(
				destination: LoginSignupForm(),
				isActive: $isLoggingIn
			) {
				PrimaryButton("Play") {
					isLoggingIn = true
				}
				.buttonBackground(.backgroundLight)
				.padding(.horizontal)
				.padding(.bottom)
			}

			if container.has(feature: .offlineMode) {
				PrimaryButton("Play offline") {
					onPlayOffline()
				}
				.buttonBackground(.backgroundLight)
				.padding(.horizontal)
				.padding(.bottom)
			}

			PrimaryButton("Settings") {
				onShowSettings()
			}
			.buttonBackground(.backgroundLight)
			.padding(.horizontal)

			Spacer()
		}
		.navigationBarTitle(isLoggingIn ? "Home" : "")
		.navigationBarHidden(true)
		.background(Color(.backgroundDark).edgesIgnoringSafeArea(.all))
	}
}

#if DEBUG
struct WelcomeViewPreview: PreviewProvider {
	static var previews: some View {
		WelcomeView(onShowSettings: { }, onPlayOffline: { })
	}
}
#endif
