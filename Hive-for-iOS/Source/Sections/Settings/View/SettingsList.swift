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

	@StateObject private var viewModel: SettingsListViewModel

	init(
		showAccount: Bool = true,
		user: Loadable<User> = .notLoaded,
		logoutResult: Loadable<Bool> = .notLoaded
	) {
		_viewModel = StateObject(
			wrappedValue: SettingsListViewModel(
				user: user,
				logoutResult: logoutResult,
				showAccount: showAccount
			)
		)
	}

	var body: some View {
		NavigationView {
			Form {
				Section(header: SectionHeader("Game")) {
					if container.has(feature: .arGameMode) {
						itemToggle(title: "Mode", selected: viewModel.preferences.gameMode) {
							viewModel.postViewAction(.switchGameMode(current: $0))
						}
					}

					if container.has(feature: .emojiReactions) {
						Toggle("Disable emoji reactions", isOn: binding(for: \.hasDisabledEmojiReactions))
							.foregroundColor(Color(.textRegular))
					}

					itemToggle(title: "Piece color scheme", selected: viewModel.preferences.pieceColorScheme) {
						viewModel.postViewAction(.switchPieceColorScheme(current: $0))
					}
				}
				.listRowBackground(Color(.backgroundLight))

				if viewModel.showAccount {
					Section(header: SectionHeader("Account"), footer: logoutButton) {
						UserPreview(viewModel.user.value?.summary)
					}
					.listRowBackground(Color(.backgroundLight))
				}

				Section(
					header: SectionHeader("About"),
					footer: HStack {
						Spacer()
						VStack(alignment: .trailing) {
							Text(AppInfo.name)
								.foregroundColor(Color(.textSecondary))
							Text(AppInfo.fullSemanticVersion)
								.foregroundColor(Color(.textSecondary))
						}
					},
					content: {
						Link(destination: URL(string: "https://github.com/josephroquedev/hive-for-ios")!) {
							Text("View Source")
								.foregroundColor(Color(.highlightRegular))
						}

						ThemeNavigationLink("Attributions", destination: { AttributionsList() })
					}
				)
				.listRowBackground(Color(.backgroundLight))

				#if DEBUG
				Section(header: SectionHeader("Features")) {
					featureToggles
				}
				.listRowBackground(Color(.backgroundLight))
				#endif
			}
			.navigationBarTitle("Settings")
			.navigationBarItems(leading: doneButton)
			.onReceive(viewModel.actionsPublisher) { handleAction($0) }
			.onAppear { viewModel.postViewAction(.onAppear) }
			.listensToAllAppStateChanges { _ in
				viewModel.postViewAction(.appStateChanged)
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}

	// MARK: Content

	private func itemToggle<I>(
		title: String,
		selected: I,
		onTap: @escaping (I) -> Void
	) -> some View where I: Identifiable, I: CustomStringConvertible {
		Button {
			onTap(selected)
		} label: {
			HStack {
				Text(title)
					.foregroundColor(Color(.textRegular))
				Spacer()
				Text(selected.description)
					.foregroundColor(Color(.textRegular))
			}
		}
	}

	// MARK: Buttons

	@ViewBuilder
	private var logoutButton: some View {
		switch viewModel.logoutResult {
		case .notLoaded, .failed, .loaded:
			BasicButton {
				viewModel.postViewAction(.logout)
			} label: {
				Text("Logout")
					.foregroundColor(Color(.textSecondary))
			}
		case .loading:
			LoadingView()
		}
	}

	private var doneButton: some View {
		Button {
			viewModel.postViewAction(.exit)
		} label: {
			Text("Done")
		}
	}

	// MARK: Features

	#if DEBUG
	private var featureToggles: some View {
		ForEach(Feature.allCases, id: \.rawValue) { feature in
			Toggle(feature.rawValue, isOn: binding(for: feature))
				.foregroundColor(Color(.textRegular))
				.disabled(!container.hasAll(of: feature.dependencies))
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
		case .setPieceColorScheme(let colorScheme):
			preferencesBinding.wrappedValue.pieceColorScheme = colorScheme
		case .logout:
			logout()
		case .closeSettings:
			container.appState.value.clearNavigation(of: .settings)
		}
	}

	private func loadProfile() {
		container.interactors.userInteractor
			.loadProfile(user: $viewModel.user)
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
	private var preferencesBinding: Binding<Preferences> {
		$viewModel.preferences.dispatched(to: container.appState, \.preferences)
	}

	private func binding(for feature: Feature) -> Binding<Bool> {
		Binding(
			get: { container.features.has(feature) },
			set: { container.appState[\.features].set(feature, to: $0) }
		)
	}

	private func binding(for preference: WritableKeyPath<Preferences, Bool>) -> Binding<Bool> {
		Binding(
			get: { preferencesBinding.wrappedValue[keyPath: preference] },
			set: { preferencesBinding.wrappedValue[keyPath: preference] = $0 }
		)
	}
}

// MARK: - Preview

#if DEBUG
struct SettingsListPreviews: PreviewProvider {
	@State private static var isOpen = true

	static var previews: some View {
		SettingsList(
			user: .loaded(User.users[0]),
			logoutResult: .loading(cached: nil, cancelBag: CancelBag())
		)
	}
}
#endif
