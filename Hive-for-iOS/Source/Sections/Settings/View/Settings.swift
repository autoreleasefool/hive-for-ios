//
//  Settings.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

struct Settings: View {
	@Environment(\.container) private var container

	@ObservedObject private var viewModel: SettingsViewModel

	@State private var userProfile: Loadable<User>

	init(
		isOpen: Binding<Bool>,
		showAccount: Bool = true,
		user: Loadable<User> = .notLoaded,
		logoutResult: Loadable<Bool> = .notLoaded
	) {
		self._userProfile = .init(initialValue: user)
		viewModel = SettingsViewModel(isOpen: isOpen, logoutResult: logoutResult, showAccount: showAccount)
	}

	var body: some View {
		NavigationView {
			ScrollView {
				VStack(spacing: .m) {
					if container.has(feature: .arGameMode) {
						sectionHeader(title: "Game")
						itemToggle(title: "Mode", selected: viewModel.preferences.gameMode) {
							self.viewModel.postViewAction(.switchGameMode(current: $0))
						}
					}

					#if DEBUG
					if container.has(feature: .featureFlags) {
						sectionHeader(title: "Features")
						featureToggles
							.padding(.horizontal, length: .m)
					}
					#endif

					if self.viewModel.showAccount {
						sectionHeader(title: "Account")
						UserPreview(userProfile.value?.summary)

						logoutButton
							.padding(.horizontal, length: .m)
					}

					sectionHeader(title: "About")
					VStack(spacing: .m) {
						viewSource
						attributions
						developer
						appInfo
					}
					.padding(.horizontal, length: .m)
				}
			}
			.background(Color(.background).edgesIgnoringSafeArea(.all))
			.navigationBarTitle("Settings")
			.navigationBarItems(leading: doneButton)
			.onReceive(viewModel.actionsPublisher) { self.handleAction($0) }
			.onReceive(userUpdate) { self.userProfile = $0 }
			.onAppear { self.viewModel.postViewAction(.onAppear) }
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}

	// MARK: Content

	private func sectionHeader(title: String) -> some View {
		HStack {
			Text(title)
				.caption()
				.foregroundColor(Color(.text))
			Spacer()
		}
		.padding(.vertical, length: .s)
		.padding(.horizontal, length: .m)
		.background(Color(.backgroundLight))
	}

	private func itemToggle<I>(
		title: String,
		selected: I,
		onTap: @escaping (I) -> Void
	) -> some View where I: Identifiable, I: CustomStringConvertible {
		Button(action: {
			onTap(selected)
		}, label: {
			HStack {
				Text(title)
					.body()
					.foregroundColor(Color(.text))
				Spacer()
				Text(selected.description)
					.body()
					.foregroundColor(Color(.text))
			}
			.padding(.horizontal, length: .m)
		})
	}

	// MARK: Buttons

	private var logoutButton: AnyView {
		func action() {
			self.viewModel.postViewAction(.logout)
		}

		switch viewModel.logoutResult {
		case .notLoaded, .failed, .loaded: return AnyView(BasicButton<Never>("Logout", action: action))
		case .loading: return AnyView(BasicButton(action: action) { ActivityIndicator(isAnimating: true, style: .white) })
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

	// MARK: Features

	#if DEBUG
	private var featureToggles: some View {
		ForEach(Feature.allCases, id: \.rawValue) { feature in
			Toggle(feature.rawValue, isOn: self.binding(for: feature))
				.foregroundColor(Color(.text))
		}
	}
	#endif

	// MARK: About

	private var viewSource: some View {
		Text("View source")
	}

	private var attributions: some View {
		Text("Attributions")
	}

	private var developer: some View {
		Text("Created by Joseph Roque")
	}

	private var appInfo: some View {
		Text("App info")
	}
}

// MARK: - Actions

extension Settings {
	private func handleAction(_ action: SettingsAction) {
		switch action {
		case .loadProfile:
			loadProfile()
		case .setGameMode(let mode):
			preferencesBinding.wrappedValue.gameMode = mode
		case .logout:
			logout()
		}
	}

	private func loadProfile() {
		container.interactors.userInteractor
			.loadProfile()
	}

	private func logout() {
		guard let account = container.account else { return }
		container.interactors.accountInteractor.logout(
			fromAccount: account,
			result: $viewModel.logoutResult
		)
	}
}

// MARK: - Updates

extension Settings {
	private var userUpdate: AnyPublisher<Loadable<User>, Never> {
		container.appState.updates(for: \.userProfile)
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
	}

	private var preferencesBinding: Binding<Preferences> {
		$viewModel.preferences.dispatched(to: container.appState, \.preferences)
	}

	private func binding(for feature: Feature) -> Binding<Bool> {
		Binding(
			get: { self.container.features.has(feature) },
			set: { self.container.appState[\.features].set(feature, to: $0) }
		)
	}
}

#if DEBUG
struct Settings_Previews: PreviewProvider {
	@State private static var isOpen = true

	static var previews: some View {
		Settings(
			isOpen: $isOpen,
			user: .loaded(User.users[0]),
			logoutResult: .loading(cached: nil, cancelBag: CancelBag())
		)
	}
}
#endif
