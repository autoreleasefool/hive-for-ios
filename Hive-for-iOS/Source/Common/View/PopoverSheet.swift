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
		let title: String
		let type: ButtonType
		let action: () -> Void

		enum ButtonType {
			case `default`
			case cancel
			case destructive
		}

		func actionSheetButton() -> ActionSheet.Button {
			switch type {
			case .default: return .default(Text(title), action: action)
			case .cancel: return .cancel(Text(title), action: action)
			case .destructive: return .destructive(Text(title), action: action)
			}
		}

		func popoverButton(isPresented: Binding<Bool>) -> some View {
			Button(action: {
				isPresented.wrappedValue = false
				DispatchQueue.main.async {
					self.action()
				}
			}, label: {
				Text(self.title)
			})
		}

		func alertAction() -> UIAlertAction {
			let style: UIAlertAction.Style
			switch type {
			case .default: style = .default
			case .cancel: style = .cancel
			case .destructive: style = .destructive
			}
			return UIAlertAction(title: title, style: style) { _ in
				self.action()
			}
		}
	}

	let title: String
	let message: String
	let buttons: [ButtonConfig]

	func actionSheet() -> ActionSheet {
		ActionSheet(
			title: Text(title),
			message: Text(message),
			buttons: buttons.map { $0.actionSheetButton() }
		)
	}

	func popover(isPresented: Binding<Bool>) -> some View {
		VStack {
			Text(self.title).padding(.top, .m)
			Divider()
			List {
				ForEach(Array(self.buttons.enumerated()), id: \.offset) { (_, button) in
					button.popoverButton(isPresented: isPresented)
				}
			}
		}
	}

	func alertController() -> UIAlertController {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		buttons.forEach {
			alert.addAction($0.alertAction())
		}
		return alert
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
