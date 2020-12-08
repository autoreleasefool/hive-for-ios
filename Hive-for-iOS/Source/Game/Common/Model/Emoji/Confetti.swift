//
//  Confetti.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-12-07.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Regex
import SwiftUI

enum Confetti: String, CaseIterable {
	case aimee = "Aimee"
	case caio = "Caio"
	case chris = "Chris"
	case dann = "Dann"
	case dario = "Dario"
	case franck = "Franck"
	case george = "George"
	case guillian = "Guillian"
	case joseph = "Joseph"
	case nabs = "Nabs"
	case scott = "Scott"

	var imageNames: [String] {
		switch self {
		case .aimee: return ["Fenton", "IceCream", "Aimee"]
		case .caio: return ["Bird", "Marble1", "Marble2", "Caio"]
		case .chris: return ["Chalk", "MooShu", "Chris"]
		case .dann: return ["Cookie", "PillBug", "Dann"]
		case .dario: return ["Android", "SpiderMan", "Dario"]
		case .franck: return ["Soccer", "Splitville", "Franck"]
		case .george: return ["Lady", "Panda", "George"]
		case .guillian: return ["Chalk", "D201", "D202", "Guillian"]
		case .joseph: return ["Hive", "Pin", "Joseph"]
		case .nabs: return ["Passport", "Watch", "Nabs"]
		case .scott: return ["MooShu", "MTG", "Scott"]
		}
	}

	var image: UIImage {
		images.randomElement() ?? UIImage()
	}

	var images: [UIImage] {
		imageNames.compactMap { UIImage(named: "Emoji/Confetti/\(rawValue)/\($0)") }
	}

	var headshot: UIImage? {
		UIImage(named: "Emoji/Confetti/\(rawValue)/\(rawValue)")
	}
}

// MARK: Regex

extension Confetti: Emoji {
	private static let messageRegex = Regex(#"CONFETTI \{([A-Za-z]+)\}"#)

	static func from(message: String) -> Confetti? {
		guard let match = Confetti.messageRegex.firstMatch(in: message),
					let optionalConfettiName = match.captures.first,
					let confettiName = optionalConfettiName else { return nil }
		return Confetti(rawValue: confettiName)
	}

	static func burstCount() -> Int {
		Int.random(in: 20...30)
	}

	func serialize() -> String {
		"CONFETTI {\(rawValue)}"
	}

	func scale() -> (start: CGFloat, end: CGFloat) {
		let scale = CGFloat.random(in: 0.75...1.25)
		return (start: scale, end: scale)
	}

	func rotationSpeed() -> EmojiRotationSpeed {
		[.fast, .medium, .slow].randomElement()!
	}

	func randomDuration() -> Double {
		Double.random(in: (3.5...4.5))
	}

	func initialDelay() -> Double {
		Double.random(in: 0...1.5)
	}

	func generatePath(with geometry: GeometryProxy) -> Path {
		let startPoint = CGPoint(
			x: CGFloat.random(in: (-geometry.size.width / 2)...(geometry.size.width / 2)),
			y: -geometry.size.height - geometry.size.height / 4
		)

		let endPoint = CGPoint(
			x: startPoint.x,
			y: CGFloat.random(in: -20...20)
		)

		var path = Path()
		path.move(to: startPoint)
		path.addLine(to: endPoint)
		return path
	}

	func shouldEaseInOut() -> Bool {
		false
	}
}
