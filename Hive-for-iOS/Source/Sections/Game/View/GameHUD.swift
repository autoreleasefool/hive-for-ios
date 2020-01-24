//
//  GameHUD.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine

struct GameHUD: View {
	@EnvironmentObject var viewModel: ARGameViewModel

	var body: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: self.viewModel.hasInformation,
				minHeight: 0,
				maxHeight: geometry.size.height * 0.5
			) {
				if self.viewModel.hasInformation.wrappedValue {
					HStack {
						Image(uiImage: Assets.Image.glyph)
							.resizable()
							.frame(width: Metrics.Spacing.standard, height: Metrics.Spacing.standard)
						Text(self.viewModel.informationToPresent!.description(in: self.viewModel.gameState))
					}
				} else {
					EmptyView()
				}
			}
		}
	}
}
