//
//  GameClientMessage.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-06.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveEngine
import WebSocketKit

enum GameClientMessage {
	case movement(RelativeMovement)
	case setOption(GameState.Option, Bool)
	case message(String)
	case readyToPlay
	case forfeit
}

extension WebSocket {
	func send(message: GameClientMessage) {
		switch message {
		case .movement(let movement):
			self.send("MOV \(movement.notation)")
		case .setOption(let option, let value):
			self.send("SET \(option) \(value)")
		case .message(let string):
			self.send("MSG \(string)")
		case .readyToPlay:
			self.send("GLHF")
		case .forfeit:
			self.send("FF")
		}
	}
}
