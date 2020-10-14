//
//  AppStateChangeListener.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-10-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

enum AppStateChange {
	case accountChanged
	case userChanged
}

struct AppStateChangeListener: ViewModifier {
	@Environment(\.container) private var container

	@State private var account: Loadable<Account> = .notLoaded
	@State private var user: Loadable<User> = .notLoaded

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
			.onReceive(userUpdates) { newUser in
				guard observedChanges.contains(.userChanged) && user != newUser else { return }
				user = newUser
				onChange(.userChanged)
			}
	}
}

// MARK: - Updates

extension AppStateChangeListener {
	private var accountUpdates: AnyPublisher<Loadable<Account>, Never> {
		container.appState.updates(for: \.account)
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
	}

	private var userUpdates: AnyPublisher<Loadable<User>, Never> {
		container.appState.updates(for: \.userProfile)
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
	}
}

extension View {
	func listensToAppStateChanges(
		_ changes: Set<AppStateChange>,
		onChange: @escaping (AppStateChange) -> Void
	) -> some View {
		modifier(AppStateChangeListener(forChanges: changes, onChange: onChange))
	}
}
