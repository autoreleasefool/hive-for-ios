//
//  Home.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct Home: View {
	@EnvironmentObject private var account: Account
	@State private var showWelcome: Bool = true

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
