//
//  InformationHUD.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-28.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct InformationHUD: View {
	@EnvironmentObject var viewModel: HiveGameViewModel

	private func debugView(for information: GameInformation, state: GameState) -> some View {
		return Text(information.description(in: state))
	}

	fileprivate func HUD(information: GameInformation, state: GameState) -> some View {
		HStack {
			Image(uiImage: ImageAsset.glyph)
				.resizable()
				.squareImage(.m)
			debugView(for: information, state: state)
		}
	}

	var body: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: self.viewModel.hasInformation,
				minHeight: 0,
				maxHeight: geometry.size.height / 2.0
			) {
				if self.viewModel.hasInformation.wrappedValue {
					self.HUD(information: self.viewModel.informationToPresent!, state: self.viewModel.gameState)
				} else {
					EmptyView()
				}
			}
		}
	}
}

#if DEBUG
struct InformationHUDPreview: PreviewProvider {
	@State static var isOpen: Bool = true

	static var previews: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: $isOpen,
				minHeight: 0,
				maxHeight: geometry.size.height / 2.0
			) {
				InformationHUD().HUD(information: .pieceClass(.queen), state: GameState())
			}
		}.edgesIgnoringSafeArea(.all)
	}
}
#endif
