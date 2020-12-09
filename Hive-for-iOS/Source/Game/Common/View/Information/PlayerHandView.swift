//
//  PlayerHandView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct PlayerHandView: View {
	@Environment(\.container) private var container
	@EnvironmentObject private var viewModel: GameViewModel

	let hand: GameInformation.PlayerHand
	@State private var didLongPress = false

	var body: some View {
		LazyVGrid(columns: [GridItem(.adaptive(minimum: Metrics.Image.l.rawValue))]) {
			ForEach(hand.piecesInHand.indices) {
				piece(hand.piecesInHand[$0])
			}
		}
	}

	private func piece(_ piece: Piece) -> some View {
		Button {
			viewModel.postViewAction(.closeInformation(withFeedback: false))
			if didLongPress {
				didLongPress = false
				viewModel.postViewAction(.enquiredFromHand(piece.class))
			} else {
				viewModel.postViewAction(.selectedFromHand(piece.owner, piece.class))
			}
		} label: {
			Image(uiImage: piece.image(forScheme: container.preferences.pieceColorScheme))
				.resizable()
				.scaledToFit()
				.squareImage(.l)
		}
	}
}

// MARK: - Preview

#if DEBUG
struct PlayerHandViewPreview: PreviewProvider {
	static var previews: some View {
		PlayerHandView(
			hand: GameInformation.PlayerHand(
				owner: .white,
				title: "White's hand",
				isPlayable: false,
				state: .init()
			)
		)
			.background(Color(.backgroundRegular))
	}
}
#endif
