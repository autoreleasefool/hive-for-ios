//
//  Features.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-06.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

struct Features: Equatable {
	private var enabled: Set<Feature> = Set(Feature.allCases.filter {
		#if DEBUG
		return $0.rollout >= .inDevelopment
		#else
		return $0.rollout >= .released
		#endif
	})

	func has(_ feature: Feature) -> Bool {
		enabled.contains(feature)
	}

	mutating func toggle(_ feature: Feature) {
		#if DEBUG
		enabled.toggle(feature)
		#endif
	}
}

enum Feature: String, CaseIterable {
	case offlineMode = "Offline Mode"
	case hiveMindAgent = "Hive Mind Agent"

	var rollout: Rollout {
		switch self {
		case .hiveMindAgent: return .inDevelopment
		case .offlineMode: return .inDevelopment
		}
	}
}

// MARK: - Rollout

extension Feature {
	enum Rollout: Comparable {
		case disabled
		case inDevelopment
		case released

		static func < (lhs: Rollout, rhs: Rollout) -> Bool {
			switch (lhs, rhs) {
			case (.disabled, .inDevelopment), (.inDevelopment, .released): return true
			default: return false
			}
		}
	}
}
