//
//  LoadingView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-11-27.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
	private let text: String?

	init(_ text: String? = nil) {
		self.text = text
	}

	@ViewBuilder
	var body: some View {
		ZStack {
			Color(.backgroundRegular)
				.edgesIgnoringSafeArea(.all)

			if let text = text {
				VStack(spacing: .m) {
					ProgressView()
					Text(text)
						.font(.body)
						.multilineTextAlignment(.center)
						.foregroundColor(Color(.textRegular))
				}
			} else {
				ProgressView()
			}
		}
	}
}
