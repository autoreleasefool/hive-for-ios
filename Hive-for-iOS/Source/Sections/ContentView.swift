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
	@Environment(\.container) private var container

	@StateObject private var viewModel = ContentViewViewModel()

	// This value can't be moved to the ViewModel because it mirrors the AppState and
	// was causing a re-render loop when in the @ObservedObject view model
	@State private var account: Loadable<Account>

	@State private var sheetNavigation: SheetNavigation?
	private var isShowingSheet: Binding<Bool> {
		Binding {
			sheetNavigation != nil
		} set: {
			if !$0 {
				container.appState.value.clearNavigation(of: sheetNavigation)
			}
		}
	}

	init(account: Loadable<Account> = .notLoaded) {
		self._account = .init(initialValue: account)
	}

	var body: some View {
		content
			.onReceive(viewModel.actionsPublisher) { handleAction($0) }
			.onReceive(accountUpdates) { account = $0 }
			.onReceive(navigationUpdates) { sheetNavigation = $0 }
			.sheet(isPresented: isShowingSheet) {
				sheetView
			}
			.inject(container)
			.plugInToaster()
	}

	@ViewBuilder
	private var content: some View {
		switch account {
		case .notLoaded: notLoadedView
		case .loading: loadingView
		case .loaded: loadedView
		case .failed: noAccountView
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		ZStack {
			Color(.backgroundRegular)
				.edgesIgnoringSafeArea(.all)

			Text("")
				.onAppear { viewModel.postViewAction(.onAppear) }
		}
	}

	private var loadingView: some View {
		ZStack {
			Color(.backgroundRegular)
				.edgesIgnoringSafeArea(.all)

			ProgressView("Logging in...")
		}
	}

	private var loadedView: some View {
		GameContentCoordinatorView()
	}

	private var noAccountView: some View {
		WelcomeView(onShowSettings: {
			container.appState.value.setNavigation(to: .settings)
		}, onLogin: {
			container.appState.value.setNavigation(to: .login)
		}, onPlayOffline: {
			viewModel.postViewAction(.playOffline)
		})
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
	private var accountUpdates: AnyPublisher<Loadable<Account>, Never> {
		container.appState.updates(for: \.account)
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
	}

	private var navigationUpdates: AnyPublisher<SheetNavigation?, Never> {
		container.appState.updates(for: \.contentSheetNavigation)
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
	}
}

// MARK: - Navigation

extension ContentView {
	enum SheetNavigation {
		case settings
		case login
	}

	@ViewBuilder
	private var sheetView: some View {
		switch sheetNavigation {
		case .settings:
			SettingsList()
				.inject(container)
		case .login:
			LoginSignupForm()
				.inject(container)
		case .none:
			EmptyView()
		}
	}
}

// MARK: - Preview

#if DEBUG
struct ContentViewPreview: PreviewProvider {
	static var previews: some View {
		ContentView(account: .failed(AccountRepositoryError.loggedOut))
			.inject(
				.init(
					appState: .init(
						.init(
							account: .failed(AccountRepositoryError.loggedOut),
							gameSetup: nil,
							contentSheetNavigation: nil,
							preferences: .init(),
							features: .init()
						)
					),
					interactors: .stub
				)
			)
	}
}
#endif
