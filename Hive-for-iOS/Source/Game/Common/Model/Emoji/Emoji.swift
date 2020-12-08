//
//  Emoji.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-08.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

protocol Emoji {
	var rawValue: String { get }

	init?(rawValue: String)

	static func from(message: String) -> Self?
}

class EmojiManager {
	private static let minimumDelayBetweenEmoji: TimeInterval = 3
	private static var lastEmojiSentAt: Date = .distantPast
	private static var lastEmojiReceivedAt: Date = .distantPast

	static let shared = EmojiManager()

	private init() {}

	func canSend(emoji: Emoji) -> Bool {
		Date().addingTimeInterval(-Self.minimumDelayBetweenEmoji) > Self.lastEmojiSentAt
	}

	func didSend(emoji: Emoji) {
		Self.lastEmojiSentAt = Date()
	}

	func canReceive(emoji: Emoji) -> Bool {
		Date().addingTimeInterval(-Self.minimumDelayBetweenEmoji) > Self.lastEmojiReceivedAt
	}

	func didReceive(emoji: Emoji) {
		Self.lastEmojiReceivedAt = Date()
	}
}
