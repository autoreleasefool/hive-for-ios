//
//  WatchContainer.swift
//  Hive-for-watchOS-Extension
//
//  Created by Joseph Roque on 2021-04-18.
//  Copyright © 2021 Joseph Roque. All rights reserved.
//

import HiveFoundation
import SwiftUI

struct WatchContainer: EnvironmentKey {
	let watchState: Store<WatchState>

	static var defaultValue: WatchContainer { WatchContainer.default }

	private static let `default` = WatchContainer(watchState: Store(WatchState()))
}

extension EnvironmentValues {
	var container: WatchContainer {
		get { self[WatchContainer.self] }
		set { self[WatchContainer.self] = newValue }
	}
}

// MARK: - Injection

extension View {
	func inject(_ watchState: WatchState) -> some View {
		let container = WatchContainer(watchState: Store(watchState))
		return inject(container)
	}

	func inject(_ watchContainer: WatchContainer) -> some View {
		return self
			.environment(\.container, watchContainer)
	}
}

// MARK: - Features

extension WatchContainer {
	var features: Features {
		watchState.value.features
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
