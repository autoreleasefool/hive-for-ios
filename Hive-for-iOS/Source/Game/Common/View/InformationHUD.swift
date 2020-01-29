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
	let information: GameInformation
	let state: GameState

	var body: some View {
		HStack {
			Image(uiImage: ImageAsset.glyph)
				.resizable()
				.frame(width: Metrics.Spacing.standard, height: Metrics.Spacing.standard)
			Text(information.description(in: state))
		}
	}
}

#if DEBUG
struct InformationHUDPreview: PreviewProvider {
	static var previews: some View {
		EmptyView()
	}
}
#endif
