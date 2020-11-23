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
	@Environment(\.toaster) private var toaster

	@StateObject private var viewModel = ContentViewViewModel()

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

	var body: some View {
		content
			.onReceive(viewModel.actionsPublisher) { handleAction($0) }
			.onReceive(navigationUpdates) { sheetNavigation = $0 }
			.listensToAppStateChanges([.accountChanged]) { _ in
				viewModel.postViewAction(.accountChanged)
			}
			.sheet(isPresented: isShowingSheet) {
				sheetView
			}
			.inject(container)
			.plugInToaster()
	}

	@ViewBuilder
	private var content: some View {
		switch container.appState.value.account {
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

			ProgressView("Logging in")
		}
	}

	private var loadedView: some View {
		GameContentCoordinatorView()
	}

	private var noAccountView: some View {
		WelcomeView(
			guestAccount: $viewModel.guestAccount,
			onShowSettings: {
				container.appState.value.setNavigation(to: .settings)
			}, onLogin: {
				container.appState.value.setNavigation(to: .login)
			}, onPlayAsGuest: {
				viewModel.postViewAction(.playAsGuest)
			}, onPlayOffline: {
				viewModel.postViewAction(.playOffline)
			}
		)
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
		case .createGuestAccount:
			createGuestAccount()
		case .loggedOut:
			clearAccount()
		case .appVersionUnsupported:
			container.appState.value.setNavigation(to: .appVersionUnsupported)
		case .showLoaf(let loaf):
			toaster.loaf.send(loaf)
		}
	}

	private func clearAccount() {
		container.interactors.accountInteractor.clearAccount()
	}

	private func loadAccount() {
		container.interactors.accountInteractor.loadAccount()
	}

	private func loadOfflineAccount() {
		container.interactors.accountInteractor.playOffline(account: nil)
	}

	private func createGuestAccount() {
		container.interactors.accountInteractor.createGuestAccount(account: $viewModel.guestAccount)
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
		case appVersionUnsupported
		case settings
		case login
	}

	@ViewBuilder
	private var sheetView: some View {
		switch sheetNavigation {
		case .appVersionUnsupported:
			AppVersionUnsupportedView()
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
		ContentView()
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
