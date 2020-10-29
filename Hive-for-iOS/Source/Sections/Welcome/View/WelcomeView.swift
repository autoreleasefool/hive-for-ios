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

	let guestAccount: LoadableSubject<Account>
	let onShowSettings: () -> Void
	let onLogin: () -> Void
	let onPlayAsGuest: () -> Void
	let onPlayOffline: () -> Void

	var body: some View {
		VStack {

			Image(uiImage: ImageAsset.glyph)
				.foregroundColor(Color(.highlightPrimary))
				.padding(.top, Metrics.Spacing.xl.rawValue)

			switch guestAccount.wrappedValue {
			case .notLoaded, .loaded, .failed:
				form
			case .loading:
				loadingView
			}

			Spacer()
		}
		.background(Color(.backgroundDark).edgesIgnoringSafeArea(.all))
	}

	@ViewBuilder
	private var form: some View {
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
	}

	private var loadingView: some View {
		VStack(spacing: 0) {
			HStack { Spacer() }
			ProgressView()
		}
	}
}

// MARK: - Preview

#if DEBUG
struct WelcomeViewPreview: PreviewProvider {
	static var previews: some View {
		WelcomeView(
			guestAccount: .constant(.notLoaded),
			onShowSettings: { },
			onLogin: { },
			onPlayAsGuest: { },
			onPlayOffline: { }
		)
	}
}
#endif
