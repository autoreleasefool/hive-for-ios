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
	let onLogin: () -> Void
	let onPlayAsGuest: () -> Void
	let onPlayOffline: () -> Void

	var body: some View {
		VStack {
			Spacer()

			Image(uiImage: ImageAsset.glyph)
				.foregroundColor(Color(.highlightPrimary))

			if container.has(feature: .accounts) {
				PrimaryButton("Login") {
					onLogin()
				}
				.buttonBackground(.backgroundLight)
				.padding(.horizontal)
				.padding(.bottom)
			}

			if container.has(feature: .guestMode) {
				PrimaryButton("Play as guest") {
					onPlayAsGuest()
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
		.background(Color(.backgroundDark).edgesIgnoringSafeArea(.all))
	}
}

#if DEBUG
struct WelcomeViewPreview: PreviewProvider {
	static var previews: some View {
		WelcomeView(onShowSettings: { }, onLogin: { }, onPlayAsGuest: { }, onPlayOffline: { })
	}
}
#endif
