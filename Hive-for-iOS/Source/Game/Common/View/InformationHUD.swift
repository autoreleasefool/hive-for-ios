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
	@EnvironmentObject var viewModel: GameViewModel

	@State private var subtitleHeight: CGFloat = 100

	fileprivate func hudHeight(maxHeight: CGFloat, information: GameInformation?) -> CGFloat {
		switch information {
		case .pieceClass, .playerHand, .rule, .settings, .reconnecting: return maxHeight * 0.75
		case .stack(let stack): return stack.count >= 4 ? maxHeight * 0.85 : maxHeight / 2
		case .gameEnd, .playerMustPass: return maxHeight * 0.5
		case .none: return 0
		}
	}

	var body: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: viewModel.presentingGameInformation,
				minHeight: 0,
				maxHeight: hudHeight(
					maxHeight: geometry.size.height,
					information: viewModel.presentedGameInformation
				),
				showsDragIndicator: true,
				dragGestureEnabled: information?.dismissable ?? true
			) {
				if isPresenting {
					HUD(information: information!, state: viewModel.gameState)
				}
			}
		}
	}

	fileprivate func HUD(information: GameInformation, state: GameState) -> some View {
		VStack(spacing: .m) {
			header(information: information)
			Divider().background(Color(.dividerRegular))
			details(information: information, state: state)
			if information.hasCloseButton {
				Divider().background(Color(.dividerRegular))
				closeButton
			}
		}
		.padding(.horizontal)
	}

	private func header(information: GameInformation) -> some View {
		VStack(alignment: .leading, spacing: .s) {
			Text(information.title)
				.font(.headline)
				.foregroundColor(Color(.textRegular))
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

			if let subtitle = information.subtitle {
				if information.prefersMarkdown {
					MarkdownView(subtitle, height: $subtitleHeight) { url in
						if let information = GameInformation(fromLink: url.absoluteString) {
							viewModel.postViewAction(.presentInformation(information))
						}
					}
					.frame(minHeight: subtitleHeight, maxHeight: subtitleHeight)
				} else {
					Text(subtitle)
						.font(.body)
						.foregroundColor(Color(.textRegular))
						.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
				}
			}
		}
		.scaleForMarkdown(hasMarkdown: information.prefersMarkdown)
	}

	@ViewBuilder
	private func details(information: GameInformation, state: GameState) -> some View {
		switch information {
		case .stack(let stack):
			PieceStack(stack: stack)
		case .pieceClass(let pieceClass):
			PieceClassDetails(pieceClass: pieceClass, state: state)
		case .playerHand(let hand):
			PlayerHandView(hand: hand)
		case .rule(let rule):
			if rule != nil {
				Button {
					viewModel.postViewAction(.presentInformation(.rule(nil)))
				} label: {
					Text("See all rules")
						.foregroundColor(Color(.highlightPrimary))
						.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
				}
			} else {
				RuleList()
			}
		case .gameEnd:
			PrimaryButton("Return to lobby") {
				viewModel.postViewAction(.returnToLobby)
			}
		case .playerMustPass:
			PrimaryButton("Pass turn") {
				viewModel.postViewAction(.closeInformation(withFeedback: false))
			}
		case .settings:
			GameSettings()
		case .reconnecting:
			ProgressView()
		}
	}

	private var closeButton: some View {
		PrimaryButton("Close") {
			viewModel.postViewAction(.closeInformation(withFeedback: true))
		}
		.buttonBackground(.backgroundLight)
	}
}

// MARK: - Actions

extension InformationHUD {
	var isPresenting: Bool {
		viewModel.presentingGameInformation.wrappedValue
	}

	var information: GameInformation? {
		viewModel.presentedGameInformation
	}
}

// MARK: ViewModifier

private extension View {
	@ViewBuilder
	func scaleForMarkdown(hasMarkdown: Bool) -> some View {
		if hasMarkdown {
			scaledToFit()
		} else {
			self
		}
	}
}

// MARK: - Preview

#if DEBUG
struct InformationHUDPreview: PreviewProvider {
	@State static var isOpen: Bool = true

	static var previews: some View {
		let information: GameInformation = .stack([
			Piece(class: .ant, owner: .white, index: 1),
			Piece(class: .beetle, owner: .black, index: 1),
			Piece(class: .beetle, owner: .white, index: 1),
			Piece(class: .beetle, owner: .black, index: 2),
			Piece(class: .beetle, owner: .white, index: 2),
			Piece(class: .mosquito, owner: .white, index: 1),
			Piece(class: .mosquito, owner: .black, index: 1),
		])
//		let information: GameInformation = .pieceClass(.ant)
//		let information: GameInformation = .playerHand(.init(player: .white, playingAs: .white, state: GameState()))
//		let information: GameInformation = .reconnecting(4)

		let hud = InformationHUD()

		return GeometryReader { geometry in
			BottomSheet(
				isOpen: $isOpen,
				minHeight: 0,
				maxHeight: hud.hudHeight(maxHeight: geometry.size.height, information: information)
			) {
				hud.HUD(information: information, state: GameState())
			}
		}.edgesIgnoringSafeArea(.bottom)
	}
}
#endif
