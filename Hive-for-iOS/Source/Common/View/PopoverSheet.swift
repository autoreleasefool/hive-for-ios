//
//  PopoverSheet.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-02-04.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct PopoverSheetConfig {
	struct ButtonConfig {
		let title: Text
		let type: ButtonType
		let action: () -> Void

		enum ButtonType {
			case `default`
			case cancel
			case destructive
		}

		func actionSheetButton() -> ActionSheet.Button {
			switch type {
			case .default: return .default(title, action: action)
			case .cancel: return .cancel(title, action: action)
			case .destructive: return .destructive(title, action: action)
			}
		}

		func popoverButton(isPresented: Binding<Bool>) -> some View {
			Button(action: {
				isPresented.wrappedValue = false
				DispatchQueue.main.async {
					self.action()
				}
			}, label: {
				self.title
			})
		}
	}

	let title: Text
	let message: Text
	let buttons: [ButtonConfig]

	func actionSheet() -> ActionSheet {
		ActionSheet(
			title: title,
			message: message,
			buttons: buttons.map { $0.actionSheetButton() }
		)
	}

	func popover(isPresented: Binding<Bool>) -> some View {
		VStack {
			self.title.padding(.top, .m)
			Divider()
			List {
				ForEach(Array(self.buttons.enumerated()), id: \.offset) { (_, button) in
					button.popoverButton(isPresented: isPresented)
				}
			}
		}
	}
}

extension View {
	func popoverSheet(
		isPresented: Binding<Bool>,
		arrowEdge: Edge = .bottom,
		configuration: @escaping () -> PopoverSheetConfig
	) -> some View {
		Group {
			if UIDevice.current.userInterfaceIdiom == .pad {
				popover(
					isPresented: isPresented,
					attachmentAnchor: .rect(.bounds),
					arrowEdge: arrowEdge
				) {
					configuration().popover(isPresented: isPresented)
				}
			} else {
				actionSheet(isPresented: isPresented) {
					configuration().actionSheet()
				}
			}
		}
	}
}
