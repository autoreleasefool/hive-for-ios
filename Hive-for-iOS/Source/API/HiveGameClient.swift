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
	private struct OpenConnection {
		let url: URL
		let ws: WebSocket
	}

	weak var delegate: HiveGameClientDelegate?

	private let client = WebSocketClient(eventLoopGroupProvider: .createNew)

	private var currentConnection: OpenConnection? {
		didSet {
			guard let connection = currentConnection else { return }
			connection.ws.onClose.whenComplete { [weak self] _ in
				guard let self = self else { return }
				self.delegate?.clientDidDisconnect(self, code: connection.ws.closeCode)
			}

			connection.ws.onText { [weak self] _, text in
				guard let self = self, let message = GameServerMessage(text) else { return }
				self.delegate?.clientDidReceiveMessage(self, message: message)
			}
		}
	}

	var isConnected: Bool {
		return !(currentConnection?.ws.isClosed ?? true)
	}

	func openConnection(to url: URL) {
		guard let scheme = url.scheme,
			let host = url.host else {
				print("Cannot open WebSocket connection without fully-formed URL: \(url)")
			return
		}

		DispatchQueue.global(qos: .userInitiated).async {
			if let connection = self.currentConnection {
				guard connection.url != url else { return }

				do {
					try connection.ws.close().wait()
				} catch {
					print("Failed to close previous WebSocket: \(error)")
				}
			}


			do {
				try self.client.connect(
					scheme: scheme,
					host: host,
					port: 80,
					path: url.path,
					headers: HTTPHeaders()
				) { [weak self] ws in
					guard let self = self else { return }
					self.currentConnection = OpenConnection(url: url, ws: ws)
					self.delegate?.clientDidConnect(self)
				}.wait()
			} catch {
				print("Failed to connect to WebSocket: \(error)")
			}
		}
	}

	func closeConnection(reason: WebSocketErrorCode?) {
		DispatchQueue.global(qos: .userInitiated).async {
			do {
				try self.currentConnection?.ws.close(code: reason ?? .normalClosure).wait()
			} catch {
				print("Failed to close WebSocket: \(error)")
			}
		}
	}

	func send(_ message: GameClientMessage) {
		currentConnection?.ws.send(message: message)
	}
}
