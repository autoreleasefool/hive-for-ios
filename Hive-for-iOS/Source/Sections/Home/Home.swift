//
//  Home.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct Home: View {
	@State var showWelcome: Bool = true

	var body: some View {
//		GeometryReader { geometry in
//			ZStack {
//				Rectangle()
//					.frame(width: geometry.size.width, height: geometry.size.height)
//					.background(Color(.background))
//					.edgesIgnoringSafeArea(.all)
//
//			}
//		}

		NavigationView {
			Group {
				if self.showWelcome {
					Welcome(showWelcome: self.$showWelcome)
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
