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
		UIImage(named: "Emoji/Basic/\(rawValue)")
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

	func serialize() -> String {
		"EMOJI {\(rawValue)}"
	}

	func scale() -> (start: CGFloat, end: CGFloat) {
		(start: 1, end: 0)
	}

	func rotationSpeed() -> EmojiRotationSpeed {
		.none
	}

	func randomDuration() -> Double {
		Double.random(in: (1.5...2.5))
	}

	func generatePath(with geometry: GeometryProxy) -> Path {
		let endPoint = CGPoint(
			x: CGFloat.random(in: (-geometry.size.width / 4)...(geometry.size.width / 4)),
			y: CGFloat.random(in: (-geometry.size.height / 8)...(geometry.size.height / 8)) - geometry.size.height / 2
		)

		let animationWidth = geometry.size.width / 4 +
			CGFloat.random(in: -geometry.size.width / 8 ... geometry.size.width / 8)
		let widthModifier: CGFloat = Bool.random()
			? animationWidth
			: -animationWidth

		let control1 = CGPoint(x: endPoint.x * 2 - widthModifier, y: endPoint.y / 3)
		let control2 = CGPoint(x: endPoint.x * -2 + widthModifier, y: endPoint.y * (2 / 3))

		var path = Path()
		path.move(to: .zero)
		path.addCurve(to: endPoint, control1: control1, control2: control2)
		return path
	}

	func shouldEaseInOut() -> Bool {
		true
	}
}
