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
