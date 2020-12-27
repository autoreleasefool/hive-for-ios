//
//  ContentView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import AuthenticationServices
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
			.background(Color(.backgroundRegular).edgesIgnoringSafeArea(.all))
			.onReceive(viewModel.actionsPublisher) { handleAction($0) }
			.onReceive(navigationUpdates) { sheetNavigation = $0 }
			.listensToAppStateChanges([.accountChanged]) { _ in
				viewModel.postViewAction(.accountChanged)
			}
			.sheet(isPresented: isShowingSheet) {
				sheetView
			}
			.alert(item: $viewModel.guestName) { alert in
				Alert(
					title: Text("Welcome!"),
					message: Text("Your name is \(alert.guestName)"),
					dismissButton: .default(Text("OK"))
				)
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
		LoadingView("Logging in")
	}

	private var loadedView: some View {
		GameContentCoordinatorView()
	}

	private var noAccountView: some View {
		WelcomeView(
			guestAccount: $viewModel.account,
			onShowSettings: {
				container.appState.value.setNavigation(to: .settings(inGame: false, showAccount: false))
			}, onLogin: {
				container.appState.value.setNavigation(to: .login)
			}, onPlayAsGuest: {
				viewModel.postViewAction(.playAsGuest)
			}, onSignInWithApple: {
				viewModel.postViewAction(.handleSignInWithApple($0))
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
		case .signInWithApple(let credentials):
			signInWithApple(credentials)
		case .createGuestAccount:
			createGuestAccount()
		case .loggedOut:
			clearAccount()
		case .appVersionUnsupported:
			container.appState.value.setNavigation(to: .appVersionUnsupported)
		case .accountNeedsInformation:
			container.appState.value.setNavigation(to: .profileUpdate(state: .newAppleAccount))
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
		container.interactors.accountInteractor.createGuestAccount(account: $viewModel.account)
	}

	private func signInWithApple(_ credentials: User.SignInWithApple.Request) {
		container.interactors.accountInteractor.signInWithApple(credentials, account: $viewModel.account)
	}
}

// MARK: - Updates

extension ContentView {
	private var accountUpdates: AnyPublisher<Loadable<AnyAccount>, Never> {
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
	enum SheetNavigation: Equatable {
		case appVersionUnsupported
		case login
		case settings(inGame: Bool, showAccount: Bool)
		case profileUpdate(state: ProfileUpdateFormViewModel.State)

		static func == (lhs: SheetNavigation, rhs: SheetNavigation) -> Bool {
			switch (lhs, rhs) {
			case (.appVersionUnsupported, .appVersionUnsupported),
					 (.login, .login),
					 (.settings, .settings),
					 (.profileUpdate, .profileUpdate):
				return true
			default:
				return false
			}
		}
	}

	@ViewBuilder
	private var sheetView: some View {
		switch sheetNavigation {
		case .appVersionUnsupported:
			AppVersionUnsupportedView()
		case .settings(let inGame, let showAccount):
			SettingsList(inGame: inGame, showAccount: showAccount)
				.inject(container)
		case .login:
			LoginSignupForm()
				.inject(container)
		case .profileUpdate(let state):
			ProfileUpdateForm(state: state)
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
						AppState(
							account: .failed(AccountRepositoryError.loggedOut),
							gameSetup: nil,
							contentSheetNavigation: nil,
							preferences: Preferences(),
							features: Features()
						)
					),
					interactors: .stub
				)
			)
	}
}
#endif
