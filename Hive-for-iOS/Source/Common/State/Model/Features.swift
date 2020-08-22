//
//  Features.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-06.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

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

	func hasAny(of features: Set<Feature>) -> Bool {
		return !enabled.isDisjoint(with: features)
	}

	mutating func toggle(_ feature: Feature) {
		#if DEBUG
		enabled.toggle(feature)
		#endif
	}

	mutating func set(_ feature: Feature, to value: Bool) {
		#if DEBUG
		enabled.set(feature, to: value)
		#endif
	}
}

enum Feature: String, CaseIterable {
	case arGameMode = "AR Game Mode"
	case emojiReactions = "Emoji Reactions"
	case featureFlags = "Feature flags"
	case matchHistory = "Match History"
	case userProfile = "User Profile"
	case hiveMindAgent = "Hive Mind Agent"
	case offlineMode = "Offline Mode"

	var rollout: Rollout {
		switch self {
		case .arGameMode: return .disabled
		case .emojiReactions: return .released
		case .hiveMindAgent: return .inDevelopment
		case .offlineMode: return .released
		case .featureFlags: return .inDevelopment
		case .matchHistory: return .disabled
		case .userProfile: return .disabled
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

// MARK: - AppContainer

extension AppContainer {
	var features: Features {
		appState.value.features
	}

	func has(feature: Feature) -> Bool {
		features.has(feature)
	}

	func hasAny(of features: Set<Feature>) -> Bool {
		self.features.hasAny(of: features)
	}
}
