//
//  DelayedLoadingIndicator.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-04.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct DelayedLoadingIndicator: View {
	let timeout: TimeInterval
	let message: String

	@State var showTimeoutMessage: Bool = false

	var timeoutMessage: some View {
		Text(message)
			.body()
			.foregroundColor(Color(.textSecondary))
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
	}

	var body: some View {
		VStack(spacing: .m) {
			Spacer()
			if showTimeoutMessage {
				ActivityIndicator(isAnimating: true, style: .whiteLarge)
				timeoutMessage
			}
			Spacer()
		}
		.padding(.all, length: .m)
		.onAppear {
			DispatchQueue.main.asyncAfter(deadline: .now() + self.timeout) {
				self.showTimeoutMessage = true
			}
		}
	}
}

#if DEBUG
struct DelayedLoadingIndicatorPreview: PreviewProvider {
	static var previews: some View {
		DelayedLoadingIndicator(timeout: 3, message: "Logging in...")
			.background(Color(.backgroundRegular).edgesIgnoringSafeArea(.all))
	}
}
#endif
