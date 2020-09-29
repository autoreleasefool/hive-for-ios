//
//  PieceStack.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-27.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct PieceStack: View {
	@EnvironmentObject var viewModel: GameViewModel
	let stack: [Piece]

	func row(piece: Piece) -> some View {
		Button(action: {
			self.viewModel.postViewAction(.closeInformation(withFeedback: false))
			self.viewModel.postViewAction(.tappedPiece(piece))
		}, label: {
			HStack(spacing: .m) {
				Image(uiImage: piece.class.image)
					.renderingMode(.template)
					.resizable()
					.scaledToFit()
					.squareImage(.m)
					.foregroundColor(Color(piece.owner.color))
				Text("\(piece.owner.description) \(piece.class.description) #\(piece.index)")
					.body()
					.foregroundColor(Color(piece.owner.color))
					.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
				if piece == stack.first || piece == stack.last {
					Spacer()
					Text(piece == stack.first ? "BOTTOM" : "TOP")
						.caption()
						.foregroundColor(Color(.textSecondary))
				}
			}
		})
		.frame(minWidth: 0, maxWidth: .infinity)
	}

	var body: some View {
		VStack {
			ForEach(stack.reversed(), id: \.description, content: row)
		}
	}
}

// MARK: - Preview

#if DEBUG
struct PieceStackPreview: PreviewProvider {
	static var previews: some View {
		PieceStack(stack: [
			Piece(class: .ant, owner: .white, index: 1),
			Piece(class: .beetle, owner: .black, index: 1),
			Piece(class: .beetle, owner: .white, index: 1),
		])
			.background(Color(.backgroundRegular))
	}
}
#endif
