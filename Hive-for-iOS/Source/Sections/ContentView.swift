//
//  ContentView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
	private let container: AppContainer

	@Environment(\.toaster) private var toaster: Toaster
	@State private var showWelcome = true
	@State private var account: Loadable<AccountV2> = .notLoaded

	init(container: AppContainer) {
		self.container = container
	}

	var body: some View {
		Group {
			if self.showWelcome {
				Welcome(showWelcome: $showWelcome)
			} else {
				content
			}
		}
		.background(Color(.background).edgesIgnoringSafeArea(.all))
		.onReceive(accountUpdate) {
			self.account = $0
			if case let .failed(error) = $0 {
				self.handleAccountError(error)
			}
		}
		.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.Account.Unauthorized)) { _ in
			self.container.interactors.accountInteractor.clearAccount()
		}
		.inject(container)
		.plugInToaster()
	}

	private var content: AnyView {
		switch account {
		case .notLoaded: return AnyView(notLoadedView)
		case .loading: return AnyView(loadingView)
		case .loaded: return AnyView(loadedView)
		case .failed: return AnyView(noAccountView)
		}
	}

	private func handleAccountError(_ error: Error) {
		if let error = error as? AccountRepositoryError {
			switch error {
			case .loggedOut:
				toaster.loaf.send(LoafState("You've been logged out", state: .error))
			case .apiError, .keychainError:
				toaster.loaf.send(LoafState("Failed to log in", state: .error))
			case .notFound:
				break
			}
		}
	}

	// MARK: - Content

	private var notLoadedView: some View {
		Text("")
			.onAppear {
				self.container.interactors.accountInteractor.loadAccount()
			}
	}

	private var loadingView: some View {
		DelayedLoadingIndicator(timeout: 3, message: "Logging in...")
	}

	private var loadedView: some View {
		RootTabView()
	}

	private var noAccountView: some View {
		LoginSignupV2()
	}

	// MARK: - Updates

	var accountUpdate: AnyPublisher<Loadable<AccountV2>, Never> {
		container.appState.updates(for: \.account)
	}
}
