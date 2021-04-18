//
//  AppStateChangeListener.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-10-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import HiveFoundation
import SwiftUI

enum AppStateChange: Hashable, Equatable {
	case accountChanged
	case toggledFeature(Feature)

	public func hash(into hasher: inout Hasher) {
		switch self {
		case .accountChanged:
			hasher.combine(0)
		case.toggledFeature(let feature):
			hasher.combine(1)
			hasher.combine(feature)
		}
	}

	public static func == (lhs: AppStateChange, rhs: AppStateChange) -> Bool {
		switch (lhs, rhs) {
		case (.accountChanged, .accountChanged): return true
		case (.accountChanged, _), (_, .accountChanged): return false

		case (.toggledFeature(let lf), .toggledFeature(let rf)): return lf == rf
		case (.toggledFeature, _), (_, .toggledFeature): return false
		}
	}

	fileprivate static var allCases: [AppStateChange] {
		[.accountChanged] + Feature.allCases.map { .toggledFeature($0) }
	}
}

struct AppStateChangeListener: ViewModifier {
	@Environment(\.container) private var container

	@State private var account: Loadable<AnyAccount> = .notLoaded
	@State private var features: Features?

	private let observedChanges: Set<AppStateChange>
	private let onChange: (AppStateChange) -> Void

	init(forChanges changes: Set<AppStateChange>, onChange: @escaping (AppStateChange) -> Void) {
		self.observedChanges = changes
		self.onChange = onChange
	}

	func body(content: Content) -> some View {
		content
			.onAppear()
			.onReceive(accountUpdates) { newAccount in
				guard observedChanges.contains(.accountChanged) && account != newAccount else { return }
				account = newAccount
				onChange(.accountChanged)
			}
			.onReceive(featureUpdates) { newFeatures in
				guard let oldFeatures = features else {
					features = newFeatures
					return
				}
				features = newFeatures
				newFeatures.changedFrom(oldFeatures)
					.filter { observedChanges.contains(.toggledFeature($0)) }
					.forEach { onChange(.toggledFeature($0)) }
			}
	}
}

// MARK: - Updates

extension AppStateChangeListener {
	private var accountUpdates: AnyPublisher<Loadable<AnyAccount>, Never> {
		container.appState.updates(for: \.account)
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
	}

	private var featureUpdates: AnyPublisher<Features, Never> {
		container.appState.updates(for: \.features)
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
	}
}

// MARK: - Feature Diff

extension Features {
	func changedFrom(_ other: Features) -> [Feature] {
		Feature.allCases.filter { other.has($0) != self.has($0) }
	}
}

// MARK: - View extension

extension View {
	func listensToAppStateChanges(
		_ changes: Set<AppStateChange>,
		onChange: @escaping (AppStateChange) -> Void
	) -> some View {
		modifier(AppStateChangeListener(forChanges: changes, onChange: onChange))
	}

	func listensToAllAppStateChanges(onChange: @escaping (AppStateChange) -> Void) -> some View {
		modifier(AppStateChangeListener(forChanges: Set(AppStateChange.allCases), onChange: onChange))
	}
}
