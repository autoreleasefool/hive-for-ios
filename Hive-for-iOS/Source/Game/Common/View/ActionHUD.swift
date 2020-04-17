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
	@EnvironmentObject var viewModel: HiveGameViewModel

	private func cancelButton(from config: PopoverSheetConfig) -> PopoverSheetConfig.ButtonConfig? {
		config.buttons.first(where: { $0.type == .cancel })
	}

	private func actionButtons(from config: PopoverSheetConfig) -> [PopoverSheetConfig.ButtonConfig] {
		config.buttons.filter { $0.type != .cancel }
	}

	private func button(for button: PopoverSheetConfig.ButtonConfig) -> some View {
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
		}
	}

	private func prompt(config: PopoverSheetConfig) -> some View {
		let actionButtons = self.actionButtons(from: config)
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

			ForEach(Array(actionButtons.enumerated()), id: \.offset) { (offset, button) in
				Group {
					self.button(for: button)
					if offset < actionButtons.count - 1 {
						Divider()
					}
				}
				.frame(minWidth: 0, maxWidth: .infinity)
			}
			.background(Color(.actionSheetBackground))
		}
			.background(
				RoundedRectangle(cornerRadius: .s)
					.fill(Color(.actionSheetBackground))
			)
			.mask(
				RoundedRectangle(cornerRadius: .s)
			)
			.frame(maxWidth: .infinity)
			.padding(.all, length: .m)
	}

	private func cancel(config: PopoverSheetConfig) -> some View {
		let cancelButton = self.cancelButton(from: config)
		return Group {
			if cancelButton != nil {
				self.button(for: cancelButton!)
					.background(Color(.actionSheetBackground))
					.mask(
						RoundedRectangle(cornerRadius: .s)
					)
					.padding(.horizontal, length: .m)
					.padding(.bottom, length: .xl)
			} else {
				EmptyView()
			}
		}
	}

	fileprivate func HUD(action: GameAction) -> some View {
		VStack {
			Spacer()
			prompt(config: action.config)
			cancel(config: action.config)
		}
	}

	var body: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: self.viewModel.hasGameAction,
				minHeight: 0,
				maxHeight: geometry.size.height / 2.0,
				showsDragIndicator: false,
				dragGestureEnabled: false,
				backgroundColor: .clear
			) {
				if self.viewModel.hasGameAction.wrappedValue {
					self.HUD(action: self.viewModel.gameActionToPresent!)
				} else {
					EmptyView()
				}
			}
		}
	}
}

#if DEBUG
struct ActionHUDPreview: PreviewProvider {
	@State static var isOpen: Bool = true

	static var previews: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: ActionHUDPreview.$isOpen,
				minHeight: 0,
				maxHeight: geometry.size.height / 2.0,
				showsDragIndicator: false,
				dragGestureEnabled: false,
				backgroundColor: .clear
			) {
				ActionHUD().HUD(action: GameAction(config: PopoverSheetConfig(
					title: "Move Ant?",
					message: "From in hand to (0, 0, 0)",
					buttons: [
						PopoverSheetConfig.ButtonConfig(title: "Move", type: .default) { },
						PopoverSheetConfig.ButtonConfig(title: "Destroy", type: .destructive) { },
						PopoverSheetConfig.ButtonConfig(title: "Cancel", type: .cancel) { },
					]
				), onClose: nil))
			}
		}.edgesIgnoringSafeArea(.bottom)
	}
}
#endif
