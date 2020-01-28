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
//			BottomSheet(
//				isOpen: self.viewModel.showPlayerHand,
//				minHeight: 0,
//				maxHeight: geometry.size.height * 0.3
//			) {
//				if self.viewModel.showPlayerHand.wrappedValue {
//					PlayerHandHUD(hand: self.viewModel.handToShow!)
//				} else {
//					EmptyView()
//				}
//			}

			BottomSheet(
				isOpen: self.viewModel.hasInformation,
				minHeight: 0,
				maxHeight: geometry.size.height * 0.5
			) {
				if self.viewModel.hasInformation.wrappedValue {
					InformationHUD(information: self.viewModel.informationToPresent!, state: self.viewModel.gameState)
				} else {
					EmptyView()
				}
			}
		}
	}
}

#if DEBUG
struct GameHUDPreview: PreviewProvider {
	static var previews: some View {
		EmptyView()
	}
}
#endif

