//
//  ActionSheetConfig.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-02-04.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

import SwiftUI

struct ActionSheetConfig {
	struct ButtonConfig {
		let title: String
		let type: ButtonType
		let action: () -> Void

		enum ButtonType {
			case `default`
			case cancel
			case destructive
		}

		var actionSheetButton: ActionSheet.Button {
			switch type {
			case .default: return .default(Text(title), action: action)
			case .cancel: return .cancel(Text(title), action: action)
			case .destructive: return .destructive(Text(title), action: action)
			}
		}
	}

	let title: String
	let message: String
	let buttons: [ButtonConfig]

	var actionSheet: ActionSheet {
		ActionSheet(
			title: Text(title),
			message: Text(message),
			buttons: buttons.map { $0.actionSheetButton }
		)
	}
}
