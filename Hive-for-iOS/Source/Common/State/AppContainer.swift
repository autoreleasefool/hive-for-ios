//
//  AppContainer.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveFoundation
import SwiftUI

struct AppContainer: EnvironmentKey {
	let appState: Store<AppState>
	let interactors: Interactors

	static var defaultValue: AppContainer { AppContainer.default }

	private static let `default` = AppContainer(
		appState: Store(AppState()),
		interactors: .stub
	)
}

extension EnvironmentValues {
	var container: AppContainer {
		get { self[AppContainer.self] }
		set { self[AppContainer.self] = newValue }
	}
}

// MARK: - Convenience accessors

extension AppContainer {
	var account: Account? {
		appState.value.account.value
	}

	var preferences: Preferences {
		appState.value.preferences
	}
}

// MARK: - Injection

extension View {
	func inject(_ appState: AppState, interactors: AppContainer.Interactors) -> some View {
		let container = AppContainer(appState: Store(appState), interactors: interactors)
		return inject(container)
	}

	func inject(_ appContainer: AppContainer) -> some View {
		return self
			.environment(\.container, appContainer)
	}
}

// MARK: - Features

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
