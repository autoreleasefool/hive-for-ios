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

	fileprivate func hudHeight(maxHeight: CGFloat, information: GameInformation?) -> CGFloat {
		switch information {
		case .piece, .pieceClass: return maxHeight / 2
		case .stack(let stack): return stack.count >= 4 ? maxHeight * 0.75 : maxHeight / 2
		case .none: return 0
		}
	}

	private func header(information: GameInformation) -> some View {
		VStack(spacing: Metrics.Spacing.s.rawValue) {
			Text(information.title)
				.title()
				.foregroundColor(Color(.text))
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
			Text(information.subtitle)
				.caption()
				.foregroundColor(Color(.textSecondary))
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
		}
			.padding(.horizontal, length: .m)
	}

	private func details(information: GameInformation) -> some View {
		Group { () -> AnyView in
			switch information {
			case .stack(let stack):
				return AnyView(
					PieceStack(stack: stack)
						.padding(.horizontal, length: .m)
				)
			default:
				return AnyView(EmptyView())
			}
		}
	}

	fileprivate func HUD(information: GameInformation, state: GameState) -> some View {
		VStack {
			header(information: information)
			Divider()
				.background(Color(ColorAsset.white))
				.padding(.all, length: .m)
			details(information: information)
		}
	}

	var body: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: self.viewModel.hasInformation,
				minHeight: 0,
				maxHeight: self.hudHeight(
					maxHeight: geometry.size.height,
					information: self.viewModel.informationToPresent
				)
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
		let information: GameInformation = .stack([
			Piece(class: .ant, owner: .white, index: 1),
			Piece(class: .beetle, owner: .black, index: 1),
			Piece(class: .beetle, owner: .white, index: 1),
			Piece(class: .beetle, owner: .black, index: 2),
//			Piece(class: .beetle, owner: .white, index: 2),
//			Piece(class: .mosquito, owner: .white, index: 1),
//			Piece(class: .mosquito, owner: .black, index: 1),
		])

		let hud = InformationHUD()

		return GeometryReader { geometry in
			BottomSheet(
				isOpen: $isOpen,
				minHeight: 0,
				maxHeight: hud.hudHeight(maxHeight: geometry.size.height, information: information)
			) {
				hud.HUD(information: information, state: GameState())
			}
		}.edgesIgnoringSafeArea(.all)
	}
}
#endif
