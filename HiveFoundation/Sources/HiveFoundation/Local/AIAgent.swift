//
//  AIAgent.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2020-06-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine

public protocol AIAgent {
	func playMove(in state: GameState) -> Movement
}

// MARK: - Configuration

public enum AgentConfiguration: CaseIterable, Identifiable {
	case random
	case hiveMind

	public var name: String {
		switch self {
		case .random: return "Random"
		case .hiveMind: return "Hive Mind"
		}
	}

	public var id: UUID {
		switch self {
		case .random: return UUID(uuidString: "d00a0d1c-eaf6-4d4f-8cf5-8f8840fe495d")!
		case .hiveMind: return UUID(uuidString: "c354b191-3f26-4d3e-bea5-d5e00bbc3eb4")!
		}
	}

	public func agent() -> AIAgent {
		switch self {
		case .random: return RandomAgent()
		case .hiveMind: return HiveMindAgent()
		}
	}

	public func isEnabled(in features: Features) -> Bool {
		switch self {
		case .random: return true
		case .hiveMind: return features.has(.hiveMindAgent)
		}
	}

	public static func exists(withId id: UUID) -> Bool {
		AgentConfiguration.allCases.contains { $0.id == id }
	}
}
