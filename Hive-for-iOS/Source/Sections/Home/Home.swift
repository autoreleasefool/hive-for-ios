//
//  Home.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Loaf

struct Home: View {
	@EnvironmentObject private var account: Account
	@State private var showWelcome: Bool = true
	@State private var loaf: Loaf?

	var body: some View {
		NavigationView {
			Group {
				if self.showWelcome {
					Welcome(showWelcome: self.$showWelcome)
				} else if account.isAuthenticated {
					Lobby()
				} else {
					LoginSignup()
				}
			}
			.background(Color(.background).edgesIgnoringSafeArea(.all))
			.onReceive(account.$isAuthenticated) { isAuthenticated in
				if !self.showWelcome && !isAuthenticated {
					self.loaf = Loaf("You've been logged out", state: .error)
				}
			}
			.loaf($loaf)
		}
	}
}

#if DEBUG
struct HomePreview: PreviewProvider {
	static var previews: some View {
		Home()
	}
}
#endif
