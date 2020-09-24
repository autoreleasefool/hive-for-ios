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
		case .piece, .pieceClass, .playerHand, .rule, .settings, .reconnecting: return maxHeight * 0.75
		case .stack(let stack): return stack.count >= 4 ? maxHeight * 0.85 : maxHeight / 2
		case .gameEnd, .playerMustPass: return maxHeight * 0.5
		case .none: return 0
		}
	}

	var body: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: self.viewModel.presentingGameInformation,
				minHeight: 0,
				maxHeight: self.hudHeight(
					maxHeight: geometry.size.height,
					information: self.viewModel.presentedGameInformation
				),
				showsDragIndicator: self.information?.dismissable ?? true,
				dragGestureEnabled: self.information?.dismissable ?? true
			) {
				if self.isPresenting {
					self.HUD(information: self.information!, state: self.viewModel.gameState)
				} else {
					EmptyView()
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
		.padding(.horizontal, length: .m)
	}

	private func header(information: GameInformation) -> some View {
		let subtitle = information.subtitle

		return VStack(alignment: .leading, spacing: .s) {
			Text(information.title)
				.subtitle()
				.foregroundColor(Color(.textRegular))
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

			if subtitle != nil {
				if information.prefersMarkdown {
					Markdown(subtitle!, height: self.$subtitleHeight) { url in
						if let information = GameInformation(fromLink: url.absoluteString) {
							self.viewModel.postViewAction(.presentInformation(information))
						}
					}
					.frame(minHeight: self.subtitleHeight, maxHeight: self.subtitleHeight)
				} else {
					Text(subtitle!)
						.body()
						.foregroundColor(Color(.textRegular))
						.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
				}
			}
		}
		.scaleForMarkdown(hasMarkdown: information.prefersMarkdown)
	}

	private func details(information: GameInformation, state: GameState) -> some View {
		Group { () -> AnyView in
			switch information {
			case .stack(let stack):
				return AnyView(PieceStack(stack: stack))
			case .pieceClass(let pieceClass):
				return AnyView(PieceClassDetails(pieceClass: pieceClass, state: state))
			case .piece(let piece):
				return AnyView(PieceClassDetails(pieceClass: piece.class, state: state))
			case .playerHand(let hand):
				return AnyView(PlayerHandView(hand: hand))
			case .rule(let rule):
				if rule != nil {
					return AnyView(
						Button(action: {
							self.viewModel.postViewAction(.presentInformation(.rule(nil)))
						}, label: {
							Text("See all rules")
								.foregroundColor(Color(.highlightPrimary))
								.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
						})
					)
				} else {
					return AnyView(RuleList())
				}
			case .gameEnd:
				return AnyView(
					BasicButton<Never>("Return to lobby") {
						self.viewModel.postViewAction(.returnToLobby)
					}
				)
			case .playerMustPass:
				return AnyView(
					BasicButton<Never>("Pass turn") {
						self.viewModel.postViewAction(.closeInformation(withFeedback: false))
					}
				)
			case .settings:
				return AnyView(GameSettings())
			case .reconnecting:
				return AnyView(ActivityIndicator(isAnimating: true, style: .large))
			}
		}
	}

	private var closeButton: some View {
		BasicButton<Never>("Close") {
			self.viewModel.postViewAction(.closeInformation(withFeedback: true))
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
	func scaleForMarkdown(hasMarkdown: Bool) -> some View {
		if hasMarkdown {
			return AnyView(self.scaledToFit())
		} else {
			return AnyView(self)
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
