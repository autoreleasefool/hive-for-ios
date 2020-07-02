//
//  ComputerEnemy.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-06-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

struct ComputerEnemy {
	let player: Player
}

// MARK: - Player

extension ComputerEnemy {
	enum Player: CaseIterable, Identifiable {
		case dumbo
		case hiveMind

		var name: String {
			switch self {
			case .dumbo: return "Dumbo"
			case .hiveMind: return "Hive Mind"
			}
		}

		var id: UUID {
			switch self {
			case .dumbo: return UUID(uuidString: "d00a0d1c-eaf6-4d4f-8cf5-8f8840fe495d")!
			case .hiveMind: return UUID(uuidString: "c354b191-3f26-4d3e-bea5-d5e00bbc3eb4")!
			}
		}
	}

	static func exists(withId id: UUID) -> Bool {
		Player.allCases.contains { $0.id == id }
	}
}