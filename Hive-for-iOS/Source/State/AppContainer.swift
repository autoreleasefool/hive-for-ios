//
//  AppContainer.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

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
