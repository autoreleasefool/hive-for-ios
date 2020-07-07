//
//  AIAgent.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-06-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine

protocol AIAgent {
	func playMove(in state: GameState) -> Movement
}

// MARK: - Configuration

enum AgentConfiguration: CaseIterable, Identifiable {
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

	var user: Match.User {
		Match.User(id: id, displayName: name, elo: 0, avatarUrl: nil)
	}

	var player: AIAgent {
		switch self {
		case .dumbo: return DumboAgent()
		case .hiveMind: return HiveMindAgent()
		}
	}

	func isEnabled(in features: Features) -> Bool {
		switch self {
		case .dumbo: return true
		case .hiveMind: return features.has(.hiveMindAgent)
		}
	}

	static func exists(withId id: UUID) -> Bool {
		AgentConfiguration.allCases.contains { $0.id == id }
	}
}
