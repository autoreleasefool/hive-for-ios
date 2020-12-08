//
//  Emoji.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-08.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

protocol Emoji {
	var rawValue: String { get }

	init?(rawValue: String)

	func serialize() -> String

	static func from(message: String) -> Self?
	func generatePath(with geometry: GeometryProxy) -> Path
	func randomDuration() -> Double
	func scale() -> (start: CGFloat, end: CGFloat)
	func rotationSpeed() -> EmojiRotationSpeed
	func shouldEaseInOut() -> Bool
}

enum EmojiRotationSpeed {
	case fast
	case medium
	case slow
	case none

	var revolutions: Double {
		switch self {
		case .fast: return 3
		case .medium: return 2
		case .slow: return 1
		case .none: return 0
		}
	}
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
