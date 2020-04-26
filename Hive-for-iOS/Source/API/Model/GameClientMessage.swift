//
//  GameClientMessage.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-06.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveEngine
import Starscream

enum GameClientMessage {
	enum Option {
		case gameOption(GameState.Option)
		case matchOption(Match.Option)

		var optionName: String {
			switch self {
			case .gameOption(let option): return option.rawValue
			case .matchOption(let option): return option.rawValue
			}
		}
	}

	case movement(RelativeMovement)
	case setOption(Option, Bool)
	case message(String)
	case readyToPlay
	case forfeit
}

extension WebSocket {
	func send(message: GameClientMessage) {
		switch message {
		case .movement(let movement):
			self.write(string: "MOV \(movement.notation)")
		case .setOption(let option, let value):
			self.write(string: "SET \(option.optionName) \(value)")
		case .message(let string):
			self.write(string: "MSG \(string)")
		case .readyToPlay:
			self.write(string: "GLHF")
		case .forfeit:
			self.write(string: "FF")
		}
	}
}
