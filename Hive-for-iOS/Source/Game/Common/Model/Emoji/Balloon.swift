//
//  Balloon.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-12-08.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Regex
import SwiftUI

enum Balloon: String, CaseIterable {
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

extension Balloon: Emoji {
	private static let messageRegex = Regex(#"EMOJI \{([A-Za-z]+)\}"#)

	static func from(message: String) -> Balloon? {
		guard let match = Balloon.messageRegex.firstMatch(in: message),
			let optionalEmojiName = match.captures.first,
			let emojiName = optionalEmojiName else { return nil }
		return Balloon(rawValue: emojiName)
	}
}
