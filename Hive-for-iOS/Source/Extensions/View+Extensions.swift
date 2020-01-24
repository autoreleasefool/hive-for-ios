//
//  View+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

extension View {
	func foregroundColor(_ asset: Assets.Color) -> some View {
		self.foregroundColor(asset.color)
	}

	func background(_ asset: Assets.Color) -> some View {
		self.background(asset.color)
	}
}
