//
//  ActivityIndicator.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-20.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
	var isAnimating: Bool

	let style: UIActivityIndicatorView.Style

	func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
		UIActivityIndicatorView(style: style)
	}

	func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
		isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
	}
}
