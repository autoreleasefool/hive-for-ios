//
//  SettingsList.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

struct SettingsList: View {
	@Environment(\.container) private var container

	@ObservedObject private var viewModel: SettingsListViewModel

	@State private var userProfile: Loadable<User>

	init(
		isOpen: Binding<Bool>,
		showAccount: Bool = true,
		user: Loadable<User> = .notLoaded,
		logoutResult: Loadable<Bool> = .notLoaded
	) {
		self._userProfile = .init(initialValue: user)
		viewModel = SettingsListViewModel(isOpen: isOpen, logoutResult: logoutResult, showAccount: showAccount)
	}

	var body: some View {
		NavigationView {
			List {
				if container.hasAny(of: [.arGameMode, .emojiReactions]) {
					Section(header: Text("Game")) {
						if !container.has(feature: .arGameMode) {
							itemToggle(title: "Mode", selected: viewModel.preferences.gameMode) {
								self.viewModel.postViewAction(.switchGameMode(current: $0))
							}
						}

						if container.has(feature: .emojiReactions) {
							Toggle("Disable emoji reactions", isOn: binding(for: \.hasDisabledEmojiReactions))
						}
					}
				}

				#if DEBUG
				if container.has(feature: .featureFlags) {
					Section(header: Text("Features")) {
						featureToggles
					}
				}
				#endif

				if self.viewModel.showAccount {
					Section(header: Text("Account")) {
						VStack(spacing: .m) {
							UserPreview(userProfile.value?.summary)
							logoutButton
						}
					}
				}

				Section(
					header: Text("About"),
					footer: HStack {
						Spacer()
						 VStack(alignment: .trailing, spacing: .xs) {
							 Text(viewModel.appName)
							 Text(viewModel.appVersion)
						 }
					 },
					content: {
						Link(
							destination: URL(string: "https://github.com/josephroquedev/hive-for-ios")!,
							label: {
								Text("View Source")
						})
						.buttonStyle(PlainButtonStyle())

						NavigationLink(
							destination: AttributionsList(),
							label: {
								Text("Attributions")
							}
						)
					}
				)
			}
			.navigationBarTitle("Settings")
			.navigationBarItems(leading: doneButton)
			.listStyle(InsetGroupedListStyle())
			.onReceive(viewModel.actionsPublisher) { self.handleAction($0) }
			.onReceive(userUpdate) { self.userProfile = $0 }
			.onAppear { self.viewModel.postViewAction(.onAppear) }
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}

	// MARK: Content

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
				Spacer()
				Text(selected.description)
			}
		})
		.buttonStyle(PlainButtonStyle())
	}

	// MARK: Buttons

	private var logoutButton: AnyView {
		func action() {
			self.viewModel.postViewAction(.logout)
		}

		switch viewModel.logoutResult {
		case .notLoaded, .failed, .loaded: return AnyView(BasicButton<Never>("Logout", action: action))
		case .loading:
			return AnyView(
				BasicButton(action: action) {
					ActivityIndicator(isAnimating: true, style: .medium)
				}
			)
		}
	}

	private var doneButton: some View {
		Button(action: {
			self.viewModel.postViewAction(.exit)
		}, label: {
			Text("Done")
		})
	}

	// MARK: Features

	#if DEBUG
	private var featureToggles: some View {
		ForEach(Feature.allCases, id: \.rawValue) { feature in
			Toggle(feature.rawValue, isOn: self.binding(for: feature))
		}
	}
	#endif
}

// MARK: - Actions

extension SettingsList {
	private func handleAction(_ action: SettingsListAction) {
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

extension SettingsList {
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

	private func binding(for preference: WritableKeyPath<Preferences, Bool>) -> Binding<Bool> {
		Binding(
			get: { self.preferencesBinding.wrappedValue[keyPath: preference] },
			set: { self.preferencesBinding.wrappedValue[keyPath: preference] = $0 }
		)
	}
}

// MARK: - Preview

#if DEBUG
struct SettingsListPreviews: PreviewProvider {
	@State private static var isOpen = true

	static var previews: some View {
		SettingsList(
			isOpen: $isOpen,
			user: .loaded(User.users[0]),
			logoutResult: .loading(cached: nil, cancelBag: CancelBag())
		)
	}
}
#endif
