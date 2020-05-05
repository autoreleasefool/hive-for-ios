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
	@State private var account: Loadable<Account> = .notLoaded

	init(container: AppContainer, account: Loadable<Account> = .notLoaded) {
		self.container = container
		self.account = account
	}

	var body: some View {
		GeometryReader { geometry in
			Group {
				if self.showWelcome {
					Welcome(showWelcome: self.$showWelcome)
				} else {
					self.content
				}
			}
			.frame(width: geometry.size.width, height: geometry.size.height)
			.background(Color(.background).edgesIgnoringSafeArea(.all))
			.onReceive(self.accountUpdate) {
				self.account = $0
				if case let .failed(error) = $0 {
					self.handleAccountError(error)
				}
			}
			.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.Account.Unauthorized)) { _ in
				self.container.interactors.accountInteractor.clearAccount()
			}
			.inject(self.container)
			.plugInToaster()
		}
	}

	private var content: AnyView {
		switch account {
		case .notLoaded: return AnyView(notLoadedView)
		case .loading: return AnyView(loadingView)
		case .loaded: return AnyView(loadedView)
		case .failed: return AnyView(noAccountView)
		}
	}

	// MARK: Content

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
		LoginSignup()
	}
}

// MARK: - Actions

extension ContentView {
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
}

// MARK: - Updates

extension ContentView {
	var accountUpdate: AnyPublisher<Loadable<Account>, Never> {
		container.appState.updates(for: \.account)
	}
}

// MARK: - Preview

#if DEBUG
struct ContentViewPreview: PreviewProvider {
	static var previews: some View {
		ContentView(container: .defaultValue, account: .loading(cached: nil, cancelBag: CancelBag()))
	}
}
#endif
