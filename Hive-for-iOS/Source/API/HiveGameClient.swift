//
//  HiveGameClient.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine
import Regex
import WebSocketKit
import NIOWebSocket

protocol HiveGameClientDelegate: class {
	func clientDidConnect(_ hiveGameClient: HiveGameClient)
	func clientDidDisconnect(_ hiveGameClient: HiveGameClient, code: WebSocketErrorCode?)
	func clientDidReceiveMessage(_ hiveGameClient: HiveGameClient, message: GameServerMessage)
}

class HiveGameClient {
	weak var delegate: HiveGameClientDelegate?

	var webSocketURL: URL?
	private var ws: WebSocket? {
		didSet {
			ws?.onClose.whenComplete { [weak self] _ in
				guard let self = self else { return }
				self.delegate?.clientDidDisconnect(self, code: self.ws?.closeCode)
			}

			ws?.onText { [weak self] _, text in
				guard let self = self,
					let message = GameServerMessage(text) else { return }
				self.delegate?.clientDidReceiveMessage(self, message: message)
			}
		}
	}

	func openConnection() {
		guard let url = webSocketURL,
			let scheme = url.scheme,
			let host = url.host else {
				print("Cannot open WebSocket connection without fully-formed URL: \(String(describing: webSocketURL))")
			return
		}

		let client = WebSocketClient(eventLoopGroupProvider: .createNew)
		_ = client.connect(
			scheme: scheme,
			host: host,
			port: 80,
			path: url.path,
			headers: HTTPHeaders()
		) { [weak self] ws in
			guard let self = self else { return }
			self.ws = ws
			self.delegate?.clientDidConnect(self)
		}
	}

	func closeConnection(reason: WebSocketErrorCode?) {
		_ = ws?.close(code: reason ?? .normalClosure)
	}

	func send(_ message: GameClientMessage) {
		ws?.send(message: message)
	}
}
