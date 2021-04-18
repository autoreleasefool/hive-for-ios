//
//  SettingsList.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import HiveFoundation
import SwiftUI

struct SettingsList: View {
	@Environment(\.container) private var container

	@StateObject private var viewModel: SettingsListViewModel

	init(
		inGame: Bool = false,
		showAccount: Bool = true,
		user: Loadable<User> = .notLoaded,
		logoutResult: Loadable<Bool> = .notLoaded
	) {
		_viewModel = StateObject(
			wrappedValue: SettingsListViewModel(
				user: user,
				logoutResult: logoutResult,
				showAccount: showAccount,
				inGame: inGame
			)
		)
	}

	var body: some View {
		NavigationView {
			Form {
				gameSettingsSection
				if !viewModel.inGame {
					appSettingsSection
				}

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

	private var gameSettingsSection: some View {
		Section(header: SectionHeader("Game")) {
			if container.has(feature: .arGameMode) {
				itemToggle(title: "Mode", selected: viewModel.preferences.gameMode) {
					viewModel.postViewAction(.switchGameMode(current: $0))
				}
			}

			if container.has(feature: .emojiReactions) {
				Toggle("Allow emote reactions", isOn: binding(for: \.isEmotesEnabled))
					.foregroundColor(Color(.textRegular))
				Toggle("Show spectator emotes", isOn: binding(for: \.isSpectatorEmotesEnabled))
					.foregroundColor(Color(.textRegular))
					.disabled(!container.preferences.isEmotesEnabled)
			}

			Toggle("Move to center on device rotation", isOn: binding(for: \.isMoveToCenterOnRotateEnabled))
				.foregroundColor(Color(.textRegular))

			Toggle("Announce spectators", isOn: binding(for: \.isSpectatorNotificationsEnabled))
				.foregroundColor(Color(.textRegular))

			VStack {
				itemToggle(title: "Piece color scheme", selected: viewModel.preferences.pieceColorScheme) {
					viewModel.postViewAction(.switchPieceColorScheme(current: $0))
				}
				HStack {
					Image(uiImage: whiteAnt)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.squareImage(.l)
					Image(uiImage: whiteBeetle)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.squareImage(.l)
					Image(uiImage: blackAnt)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.squareImage(.l)
					Image(uiImage: blackBeetle)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.squareImage(.l)
				}
				.padding()
			}
		}
		.listRowBackground(Color(.backgroundLight))
	}

	@ViewBuilder
	private var appSettingsSection: some View {
		if viewModel.showAccount {
			Section(header: SectionHeader("Account")) {
				UserPreview(viewModel.user.value?.summary)

				Button("Edit profile") {
					viewModel.postViewAction(.updateProfile)
				}
				.foregroundColor(Color(.highlightRegular))

				Button("Logout") {
					viewModel.postViewAction(.logout)
				}
				.foregroundColor(Color(.highlightPrimary))
			}
			.listRowBackground(Color(.backgroundLight))
		}

		Section(
			header: SectionHeader("About"),
			footer: VStack {
				HStack {
					Spacer()
					VStack(alignment: .trailing) {
						Text(AppInfo.name)
							.foregroundColor(Color(.textSecondary))
						Text(AppInfo.fullSemanticVersion)
							.foregroundColor(Color(.textSecondary))
					}
				}
				Text("Hive is copyright of Gen42 Games. Hive Mobile and its associated elements are not " +
							"produced by, endorsed by, nor affiliated in any way with Gen42 Games.")
					.font(.caption)
					.foregroundColor(Color(.textSecondary))
					.padding(.top, Metrics.Spacing.m.rawValue)
			},
			content: {
				Link(destination: URL(string: "https://github.com/autoreleasefool/hive-for-ios")!) {
					Text("View Source")
						.foregroundColor(Color(.highlightRegular))
				}

				Link(destination: URL(string: "https://hive.josephroque.dev/privacy")!) {
					Text("Privacy Policy")
						.foregroundColor(Color(.highlightRegular))
				}

				ThemeNavigationLink("Attributions", destination: { AttributionsList() })
			}
		)
		.listRowBackground(Color(.backgroundLight))
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

	// MARK: Pieces

	private var whiteAnt: UIImage {
		switch container.preferences.pieceColorScheme {
		case .filled:
			return ImageAsset.Pieces.White.Filled.ant
		default:
			return ImageAsset.Pieces.White.ant
		}
	}

	private var whiteBeetle: UIImage {
		switch container.preferences.pieceColorScheme {
		case .filled:
			return ImageAsset.Pieces.White.Filled.beetle
		default:
			return ImageAsset.Pieces.White.beetle
		}
	}

	private var blackAnt: UIImage {
		switch container.preferences.pieceColorScheme {
		case .filled:
			return ImageAsset.Pieces.Black.Filled.ant
		default:
			return ImageAsset.Pieces.Black.ant
		}
	}

	private var blackBeetle: UIImage {
		switch container.preferences.pieceColorScheme {
		case .filled:
			return ImageAsset.Pieces.Black.Filled.beetle
		default:
			return ImageAsset.Pieces.Black.beetle
		}
	}
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
		case .updateProfile:
			container.appState[\.contentSheetNavigation] = .profileUpdate(state: .default)
		case .logout:
			logout()
		case .closeSettings:
			container.appState[\.contentSheetNavigation] = nil
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
