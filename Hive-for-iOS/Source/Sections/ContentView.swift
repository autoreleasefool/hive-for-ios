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

	@ObservedObject private var viewModel: ContentViewViewModel

	init(container: AppContainer, account: Loadable<Account> = .notLoaded) {
		self.container = container
		self.viewModel = ContentViewViewModel(account: account)
	}

	var body: some View {
		GeometryReader { geometry in
			Group {
				if self.viewModel.routing.showWelcome {
					Welcome(showWelcome: self.welcomeRoutingBinding)
				} else {
					self.content
				}
			}
			.frame(width: geometry.size.width, height: geometry.size.height)
			.background(Color(.background).edgesIgnoringSafeArea(.all))
			.onReceive(self.viewModel.actionsPublisher) { self.handleAction($0) }
			.onReceive(self.accountUpdate) { self.viewModel.account = $0 }
			.onReceive(self.routingUpdate) { self.viewModel.routing = $0 }
			.sheet(isPresented: self.settingsRoutingBinding) {
				Settings()
			}
			.inject(self.container)
			.plugInToaster()
		}
	}

	private var content: AnyView {
		switch viewModel.account {
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
		RootTabView()
	}

	private var noAccountView: some View {
		LoginSignup()
	}
}

// MARK: - Actions

extension ContentView {
	private func handleAction(_ action: ContentViewAction) {
		switch action {
		case .loadAccount:
			loadAccount()
		case .loggedOut:
			container.interactors.accountInteractor.clearAccount()
		}
	}

	private func loadAccount() {
		self.container.interactors.accountInteractor.loadAccount()
	}
}

// MARK: - Updates

extension ContentView {
	private var accountUpdate: AnyPublisher<Loadable<Account>, Never> {
		container.appState.updates(for: \.account)
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}
}

// MARK: - Routing

extension ContentView {
	struct Routing: Equatable {
		var settingsIsOpen: Bool = false
		var showWelcome: Bool = true
	}

	private var routingUpdate: AnyPublisher<Routing, Never> {
		container.appState.updates(for: \.routing.mainRouting)
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	private var settingsRoutingBinding: Binding<Bool> {
		$viewModel.routing.settingsIsOpen
			.dispatched(to: container.appState, \.routing.mainRouting.settingsIsOpen)
	}

	private var welcomeRoutingBinding: Binding<Bool> {
		$viewModel.routing.showWelcome
			.dispatched(to: container.appState, \.routing.mainRouting.showWelcome)
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
