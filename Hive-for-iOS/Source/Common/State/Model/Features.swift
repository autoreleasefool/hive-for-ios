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
		return $0.rollout == .inDevelopment || $0.rollout == .released
		#else
		return $0.rollout == .released
		#endif
	})

	func has(_ feature: Feature) -> Bool {
		enabled.contains(feature) && hasAll(of: feature.dependencies)
	}

	func hasAny(of features: Set<Feature>) -> Bool {
		features.contains { has($0) }
	}

	func hasAll(of features: Set<Feature>) -> Bool {
		features.allSatisfy { has($0) }
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
	case matchHistory = "Match History"
	case profileList = "Profile List"
	case spectating = "Spectating"
	case hiveMindAgent = "Hive Mind Agent"
	case accounts = "Accounts"
	case signInWithApple = "Sign in with Apple"
	case guestMode = "Guest Mode"
	case offlineMode = "Offline Mode"
	case aiOpponents = "AI Opponents"
	case emojiMasterMode = "Emoji Master Mode"

	var rollout: Rollout {
		switch self {
		case .arGameMode: return .disabled
		case .emojiReactions: return .released
		case .hiveMindAgent: return .disabled
		case .offlineMode: return .released
		case .accounts: return .disabled
		case .signInWithApple: return .inDevelopment
		case .guestMode: return .disabled
		case .matchHistory: return .disabled
		case .profileList: return .disabled
		case .spectating: return .released
		case .aiOpponents: return .released
		case .emojiMasterMode: return .inDevelopment
		}
	}

	var dependencies: Set<Feature> {
		switch self {
		case .offlineMode:
			return [.aiOpponents]
		case .hiveMindAgent:
			return [.aiOpponents]
		case .emojiMasterMode:
			return [.emojiReactions]
		case .matchHistory, .profileList:
			return [.signInWithApple]
		case .arGameMode, .emojiReactions, .aiOpponents, .spectating, .guestMode, .signInWithApple, .accounts:
			return []
		}
	}
}

// MARK: - Rollout

extension Feature {
	enum Rollout {
		case disabled
		case inDevelopment
		case released
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

	func hasAll(of features: Set<Feature>) -> Bool {
		self.features.hasAll(of: features)
	}
}
