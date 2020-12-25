//
//  EventHUD.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-25.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct EventHUD: View {
	@EnvironmentObject var viewModel: GameViewModel
	@Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

	private func cancelButton(from config: GameEvent.Config) -> GameEvent.ButtonConfig? {
		config.buttons.first(where: { $0.type == .cancel })
	}

	private func actionButtons(from config: GameEvent.Config) -> [GameEvent.ButtonConfig] {
		config.buttons.filter { $0.type != .cancel }
	}

	private func button(for button: GameEvent.ButtonConfig) -> some View {
		Button(action: button.action) {
			HStack {
				if button.type == .destructive {
					Text(button.title)
						.foregroundColor(Color(.highlightDestructive))
						.font(.body)
				} else if button.type == .cancel {
					Text(button.title)
						.foregroundColor(Color(.textContrastingSecondary))
						.font(.body)
				} else {
					Text(button.title)
						.foregroundColor(Color(.textContrasting))
						.bold()
						.font(.body)
				}
			}
			.frame(minWidth: 0, maxWidth: .infinity)
			.padding()
			.background(Color(.actionSheetBackground))
		}
	}

	private func prompt(config: GameEvent.Config) -> some View {
		let actionButtons = self.actionButtons(from: config)
		return VStack(spacing: 0) {
			HStack { Spacer() }

			VStack {
				Text(config.title)
					.bold()
					.font(.headline)
					.foregroundColor(Color(.textContrasting))
				Text(config.message)
					.font(.body)
					.foregroundColor(Color(.textContrasting))
			}
			.padding()

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
			.padding()
	}

	private func cancel(config: GameEvent.Config) -> some View {
		let cancelButton = self.cancelButton(from: config)
		return Group {
			if cancelButton != nil {
				self.button(for: cancelButton!)
					.background(Color(.actionSheetBackground))
					.mask(
						RoundedRectangle(cornerRadius: .s)
					)
					.padding(.horizontal)
					.padding(.bottom)
			} else {
				EmptyView()
			}
		}
	}

	fileprivate func HUD(event: GameEvent) -> some View {
		VStack {
			Spacer()
			prompt(config: event.config)
			cancel(config: event.config)
		}
		.limitWidth(forSizeClass: horizontalSizeClass)
	}

	var body: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: viewModel.presentingGameEvent,
				minHeight: 0,
				maxHeight: geometry.size.height / 2.0,
				showsDragIndicator: false,
				dragGestureEnabled: false,
				backgroundColor: .clear
			) {
				if viewModel.presentingGameEvent.wrappedValue {
					HUD(event: viewModel.presentedGameEvent!)
				} else {
					EmptyView()
				}
			}
			.edgesIgnoringSafeArea(.top)
		}
	}
}

// MARK: - Preview

#if DEBUG
struct EventHUDPreview: PreviewProvider {
	@State static var isOpen: Bool = true

	static var previews: some View {
		GeometryReader { geometry in
			BottomSheet(
				isOpen: EventHUDPreview.$isOpen,
				minHeight: 0,
				maxHeight: geometry.size.height / 2.0,
				showsDragIndicator: false,
				dragGestureEnabled: false,
				backgroundColor: .clear
			) {
				EventHUD().HUD(event: GameEvent(config: GameEvent.Config(
					title: "Move Ant?",
					message: "From in hand to (0, 0, 0)",
					buttons: [
						GameEvent.ButtonConfig(title: "Move", type: .default) { },
						GameEvent.ButtonConfig(title: "Destroy", type: .destructive) { },
						GameEvent.ButtonConfig(title: "Cancel", type: .cancel) { },
					]
				), onClose: nil))
			}
		}
	}
}
#endif
