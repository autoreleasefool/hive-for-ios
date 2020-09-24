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

	@ObservedObject private var viewModel: ContentViewViewModel

	// This value can't be moved to the ViewModel because it mirrors the AppState and
	// was causing a re-render loop when in the @ObservedObject view model
	@State private var account: Loadable<Account>

	init(container: AppContainer, account: Loadable<Account> = .notLoaded) {
		self.container = container
		self._account = .init(initialValue: account)
		self.viewModel = ContentViewViewModel()
	}

	var body: some View {
		GeometryReader { geometry in
			Group {
				if self.viewModel.showWelcome {
					Welcome(
						showWelcome: self.$viewModel.showWelcome,
						playingOffline: self.$viewModel.playingOffline,
						showSettings: self.$viewModel.showSettings
					)
				} else {
					self.content
				}
			}
			.frame(width: geometry.size.width, height: geometry.size.height)
			.background(Color(.backgroundRegular).edgesIgnoringSafeArea(.all))
			.onReceive(self.viewModel.actionsPublisher) { self.handleAction($0) }
			.onReceive(self.accountUpdate) { self.account = $0 }
			.sheet(isPresented: self.$viewModel.showSettings) {
				Settings(isOpen: self.$viewModel.showSettings, showAccount: false)
					.inject(self.container)
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
			.onAppear { self.viewModel.postViewAction(.onAppear) }
	}

	private var loadingView: some View {
		DelayedLoadingIndicator(timeout: 3, message: "Logging in...")
	}

	private var loadedView: some View {
		GameContentCoordinator()
	}

	private var noAccountView: some View {
		LoginSignup {
			self.viewModel.showWelcome = true
		}
	}
}

// MARK: - Actions

extension ContentView {
	private func handleAction(_ action: ContentViewAction) {
		switch action {
		case .loadOfflineAccount:
			loadOfflineAccount()
		case .loadAccount:
			loadAccount()
		case .loggedOut:
			container.interactors.accountInteractor.clearAccount()
		}
	}

	private func loadAccount() {
		container.interactors.accountInteractor.loadAccount()
	}

	private func loadOfflineAccount() {
		container.interactors.accountInteractor.playOffline(account: nil)
	}
}

// MARK: - Updates

extension ContentView {
	private var accountUpdate: AnyPublisher<Loadable<Account>, Never> {
		container.appState.updates(for: \.account)
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
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
