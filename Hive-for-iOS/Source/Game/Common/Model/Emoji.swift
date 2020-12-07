//
//  Emoji.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-08.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Regex
import SwiftUI

enum Emoji: String, CaseIterable {
	case noJo = "NoJo"
	case hive = "Hive"
	case scottCry = "ScottCry"
	case mobileExperience = "MobileExperience"
	case dead = "Dead"
	case noGeorge = "NoGeorge"

	var image: UIImage? {
		UIImage(named: "Emoji/\(rawValue)")
	}
}

// MARK: Regex

extension Emoji {
	private static let messageRegex = Regex(#"EMOJI \{([A-Za-z]+)\}"#)

	static func from(message: String) -> Emoji? {
		guard let match = Emoji.messageRegex.firstMatch(in: message),
			let optionalEmojiName = match.captures.first,
			let emojiName = optionalEmojiName else { return nil }
		return Emoji(rawValue: emojiName)
	}
}

// MARK: Restrictions

extension Emoji {
	private static let minimumDelayBetweenEmoji: TimeInterval = 3
	private static var lastEmojiSentAt: Date = .distantPast
	private static var lastEmojiReceivedAt: Date = .distantPast

	static func canSend(emoji: Emoji) -> Bool {
		Date().addingTimeInterval(-minimumDelayBetweenEmoji) > lastEmojiSentAt
	}

	static func didSend(emoji: Emoji) {
		lastEmojiSentAt = Date()
	}

	static func canReceive(emoji: Emoji) -> Bool {
		Date().addingTimeInterval(-minimumDelayBetweenEmoji) > lastEmojiReceivedAt
	}

	static func didReceive(emoji: Emoji) {
		lastEmojiReceivedAt = Date()
	}
}
