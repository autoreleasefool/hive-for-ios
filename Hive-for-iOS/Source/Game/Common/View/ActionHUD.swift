//
//  ActionHUD.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-25.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct ActionHUD: View {
//	@EnvironmentObject var viewModel: HiveGameViewModel
	let action: GameAction

	var cancelButton: PopoverSheetConfig.ButtonConfig? {
		return action.config.buttons.first(where: { $0.type == .cancel })
	}

	var actionButtons: [PopoverSheetConfig.ButtonConfig] {
		return action.config.buttons.filter { $0.type != .cancel }
	}

	func button(for button: PopoverSheetConfig.ButtonConfig) -> some View {
		Button(action: button.action) {
			HStack {
				if button.type == .destructive {
					Text(button.title)
						.foregroundColor(Color(.destructive))
						.body()
				} else if button.type == .cancel {
					Text(button.title)
						.foregroundColor(Color(.textContrastingSecondary))
						.body()
				} else {
					Text(button.title)
						.foregroundColor(Color(.textContrasting))
						.bold()
						.body()
				}
			}
			.frame(minWidth: 0, maxWidth: .infinity)
			.padding(length: .m)
			.background(Color(.actionSheetBackground))
//				RoundedRectangle(cornerRadius: Metrics.Spacing.s.rawValue)
//					.fill(Color(.actionSheetBackground))
//			)
		}
	}

	var prompt: some View {
		let config = action.config

		return VStack(spacing: 0) {
			HStack { Spacer() }

			VStack {
				Text(config.title)
					.bold()
					.subtitle()
					.foregroundColor(Color(.textContrasting))
				Text(config.message)
					.body()
					.foregroundColor(Color(.textContrasting))
					.padding(.top, length: .s)
			}
			.padding(length: .m)

			Divider()

			ForEach(Array(self.actionButtons.enumerated()), id: \.offset) { (offset, button) in
				Group {
					self.button(for: button)
					if offset < self.actionButtons.count - 1 {
						Divider()
					}
				}
				.frame(minWidth: 0, maxWidth: .infinity)
			}
			.background(Color(.actionSheetBackground))
		}
			.background(
				RoundedRectangle(cornerRadius: Metrics.Spacing.s.rawValue)
					.fill(Color(.actionSheetBackground))
			)
			.mask(
				RoundedRectangle(cornerRadius: Metrics.Spacing.s.rawValue)
			)
			.frame(maxWidth: .infinity)
			.padding(.all, length: .m)
	}

	var cancel: some View {
		Group {
			if cancelButton != nil {
				self.button(for: self.cancelButton!)
					.background(Color(.actionSheetBackground))
					.mask(
						RoundedRectangle(cornerRadius: Metrics.Spacing.s.rawValue)
					)
					.padding(.horizontal, length: .m)
					.padding(.bottom, length: .xl)
			} else {
				EmptyView()
			}
		}
	}

	var body: some View {
		return VStack {
			Spacer()
			prompt
			cancel
		}
	}
}

#if DEBUG
struct ActionHUDPreview: PreviewProvider {
	static var isOpen: Binding<Bool> {
		return Binding(
			get: { true },
			set: { _ in }
		)
	}

	static var previews: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: ActionHUDPreview.isOpen,
				minHeight: 0,
				maxHeight: geometry.size.height / 2.0,
				showsDragIndicator: false,
				dragGestureEnabled: false,
				backgroundColor: .primary
			) {
				ActionHUD(action: .confirmMovement(PopoverSheetConfig(
					title: "Move Ant?",
					message: "From in hand to (0, 0, 0)",
					buttons: [
						PopoverSheetConfig.ButtonConfig(title: "Move", type: .default) { },
						PopoverSheetConfig.ButtonConfig(title: "Destroy", type: .destructive) { },
						PopoverSheetConfig.ButtonConfig(title: "Cancel", type: .cancel) { },
					]
				)))
			}
		}
			.background(Color(.backgroundDark))
	}
}
#endif
