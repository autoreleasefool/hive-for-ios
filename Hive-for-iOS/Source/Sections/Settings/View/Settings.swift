//
//  Settings.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct Settings: View {
	@Environment(\.container) private var container: AppContainer

	@ObservedObject private var viewModel: SettingsViewModel

	init(logoutResult: Loadable<Bool> = .notLoaded) {
		viewModel = SettingsViewModel(logoutResult: logoutResult)
	}

	var body: some View {
		NavigationView {
			List {
				logoutButton
			}
			.navigationBarTitle("Settings")
			.navigationBarItems(leading: doneButton)
			.onReceive(viewModel.actionsPublisher) { self.handleAction($0) }
		}
	}

	// MARK: Buttons

	private var logoutButton: some View {
		Button(action: {
			self.viewModel.postViewAction(.logout)
		}, label: {
			self.logoutButtonLabel
				.body()
				.foregroundColor(Color(.background))
				.frame(minWidth: 0, maxWidth: .infinity)
				.background(
					RoundedRectangle(cornerRadius: .s)
						.size(width: .infinity, height: 48)
						.fill(Color(.primary))
				)
		})
	}

	private var logoutButtonLabel: AnyView {
		switch viewModel.logoutResult {
		case .notLoaded, .failed, .loaded: return AnyView(Text("Logout"))
		case .loading: return AnyView(ActivityIndicator(isAnimating: true, style: .white))
		}
	}

	private var doneButton: some View {
		Button(action: {
			self.viewModel.postViewAction(.exit)
		}, label: {
			Text("Done")
				.body()
				.foregroundColor(Color(.text))
		})
	}
}

// MARK: - Actions

extension Settings {
	private func handleAction(_ action: SettingsAction) {
		switch action {
		case .exit:
			exit()
		case .logout:
			logout()
		}
	}

	private func exit() {
		container.appState[\.routing.mainRouting.settingsIsOpen] = false
	}

	private func logout() {
		guard let account = container.account else { return }
		container.interactors.accountInteractor.logout(
			fromAccount: account,
			result: $viewModel.logoutResult
		)
	}
}
