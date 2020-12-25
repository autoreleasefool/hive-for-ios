//
//  GameEvent.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-25.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

struct GameEvent {
	let config: Config
	let onClose: (() -> Void)?

	struct Config {
		let title: String
		let message: String
		let buttons: [ButtonConfig]
	}

	struct ButtonConfig {
		let title: String
		let type: ButtonType
		let action: () -> Void

		enum ButtonType {
			case `default`
			case cancel
			case destructive
		}
	}
}
