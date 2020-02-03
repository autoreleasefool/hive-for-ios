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

	private func view(for information: GameInformation) -> AnyView {
		switch information {
		case .piece, .pieceClass:
			return AnyView(debugView(for: information))
		case .movement(let movement):
			return AnyView(MovementConfirmation(movement: movement))
		}
	}

	private func debugView(for information: GameInformation) -> some View {
		return Text(information.description(in: state))
	}

	var body: some View {
		HStack {
			Image(uiImage: ImageAsset.glyph)
				.resizable()
				.squareImage(.m)
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
