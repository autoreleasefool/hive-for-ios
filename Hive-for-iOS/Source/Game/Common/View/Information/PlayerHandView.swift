//
//  PlayerHandView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct PlayerHandView: View {
	@EnvironmentObject private var viewModel: GameViewModel

	let hand: GameInformation.PlayerHand
	@State private var didLongPress = false

	var body: some View {
		LazyVGrid(columns: [GridItem(.adaptive(minimum: Metrics.Image.l.rawValue))]) {
			ForEach(hand.piecesInHand.indices) {
				piece(pieceClass: hand.piecesInHand[$0])
			}
		}
	}

	private func piece(pieceClass: Piece.Class) -> some View {
		Button {
			viewModel.postViewAction(.closeInformation(withFeedback: false))
			if didLongPress {
				didLongPress = false
				viewModel.postViewAction(.enquiredFromHand(pieceClass))
			} else {
				viewModel.postViewAction(.selectedFromHand(hand.player, pieceClass))
			}
		} label: {
			Image(uiImage: pieceClass.image)
				.renderingMode(.template)
				.resizable()
				.scaledToFit()
				.squareImage(.l)
				.foregroundColor(Color(hand.player.color))
		}
	}
}

// MARK: - Preview

#if DEBUG
struct PlayerHandViewPreview: PreviewProvider {
	static var previews: some View {
		PlayerHandView(hand: .init(player: .white, playingAs: .black, state: .init()))
			.background(Color(.backgroundRegular))
	}
}
#endif
