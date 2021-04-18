//
//  GameClientMessage.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2020-04-06.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveEngine
import Foundation

public enum GameClientMessage {
	public enum Option {
		case gameOption(GameState.Option)
		case customOption(String)

		public var optionName: String {
			switch self {
			case .gameOption(let option): return option.rawValue
			case .customOption(let option): return option
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
	public func send(message: GameClientMessage, completionHandler: @escaping (Error?) -> Void) {
		switch message {
		case .movement(let movement):
			send(.string("MOV \(movement.notation)"), completionHandler: completionHandler)
		case .setOption(let option, let value):
			send(.string("SET \(option.optionName) \(value)"), completionHandler: completionHandler)
		case .message(let string):
			send(.string("MSG \(string)"), completionHandler: completionHandler)
		case .readyToPlay:
			send(.string("GLHF"), completionHandler: completionHandler)
		case .forfeit:
			send(.string("FF"), completionHandler: completionHandler)
		}
	}
}
