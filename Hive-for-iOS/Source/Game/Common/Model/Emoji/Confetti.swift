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
		case .aimee: return ["Fenton", "IceCream"]
		case .caio: return ["Bird", "Marble1", "Marble2"]
		case .chris: return ["Chalk", "MooShu"]
		case .dann: return ["Cookie", "PillBug"]
		case .dario: return ["Android", "SpiderMan"]
		case .franck: return ["Soccer", "Splitville"]
		case .george: return ["Lady", "Panda"]
		case .guillian: return ["Chalk", "D201", "D202"]
		case .joseph: return ["Hive", "Pin"]
		case .nabs: return ["Passport", "Watch"]
		case .scott: return ["MooShu", "MTG"]
		}
	}

	var images: [UIImage] {
		imageNames.compactMap { UIImage(named: "Confetti/\(rawValue)/\($0)") }
	}

	var headshot: UIImage? {
		UIImage(named: "Confetti\(rawValue)/\(rawValue)")
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
}
