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
		VStack {
			Spacer()
			HStack {
				Image(uiImage: Assets.Image.glyph)
//				VStack {
//					Text(self.arGameState.previewedPieceName)
//					Text(self.arGameState.previewedPieceDescription)
//				}
			}
		}
	}
}
