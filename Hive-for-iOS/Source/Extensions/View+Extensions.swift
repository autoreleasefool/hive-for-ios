//
//  View+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-12-25.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

extension View {
	func limitWidth(
		forSizeClass horizontalSizeClass: UserInterfaceSizeClass?,
		forCompactLayouts: CGFloat = .infinity,
		forRegularLayouts: CGFloat = 500
	) -> some View {
		self.frame(
			maxWidth: horizontalSizeClass == .compact
				? forCompactLayouts
				: forRegularLayouts
		)
	}
}

extension View {
	func hideOnRotate(show: Binding<Bool>) -> some View {
		onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
			show.wrappedValue = false
		}
	}
}
