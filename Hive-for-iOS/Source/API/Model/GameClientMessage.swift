//
//  GameClientMessage.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-06.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveEngine
import Foundation

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

extension URLSessionWebSocketTask {
	func send(message: GameClientMessage, completionHandler: @escaping (Error?) -> Void) {
		switch message {
		case .movement(let movement):
			self.send(.string("MOV \(movement.notation)"), completionHandler: completionHandler)
		case .setOption(let option, let value):
			self.send(.string("SET \(option.optionName) \(value)"), completionHandler: completionHandler)
		case .message(let string):
			self.send(.string("MSG \(string)"), completionHandler: completionHandler)
		case .readyToPlay:
			self.send(.string("GLHF"), completionHandler: completionHandler)
		case .forfeit:
			self.send(.string("FF"), completionHandler: completionHandler)
		}
	}
}
