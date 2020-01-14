//
//  Home.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct HomeView: View {
	var body: some View {
		NavigationView {
			VStack {
				HStack {
					Spacer()
				}
				Spacer()

				Image(uiImage: Assets.Image.glyph)
					.foregroundColor(Assets.Color.primary)

				NavigationLink(
					destination: RoomList()
				) {
					Text("Play")
						.font(.system(size: Metrics.Text.subtitle))
						.foregroundColor(.text)
						.padding(EdgeInsets(equal: Metrics.Spacing.standard))
				}

				NavigationLink(
					destination: RoomList()
				) {
					Text("Settings")
						.font(.system(size: Metrics.Text.subtitle))
						.foregroundColor(.text)
						.padding(EdgeInsets(equal: Metrics.Spacing.standard))
				}

				Spacer()
			}
			.background(Assets.Color.background)
			.edgesIgnoringSafeArea(.all)
		}
		.navigationBarHidden(true)
	}
}
