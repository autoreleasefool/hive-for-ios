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
			List {
				if container.hasAny(of: [.arGameMode, .emojiReactions]) {
					Section(header: sectionHeader(title: "Game")) {
						if container.has(feature: .arGameMode) {
							itemToggle(title: "Mode", selected: viewModel.preferences.gameMode) {
								self.viewModel.postViewAction(.switchGameMode(current: $0))
							}
						}

						if container.has(feature: .emojiReactions) {
							Toggle("Disable emoji reactions", isOn: binding(for: \.hasDisabledEmojiReactions))
								.foregroundColor(Color(.textRegular))
								.padding(.vertical, length: .xs)
						}
					}
				}

				#if DEBUG
				if container.has(feature: .featureFlags) {
					Section(header: sectionHeader(title: "Features")) {
						featureToggles
					}
				}
				#endif

				if self.viewModel.showAccount {
					Section(header: sectionHeader(title: "Account")) {
						VStack(spacing: .m) {
							UserPreview(userProfile.value?.summary)
							logoutButton
						}
					}
				}

				Section(header: sectionHeader(title: "About")) {
					viewSource
					attributions
					appInfo
				}

				NavigationLink(
					destination: AttributionsList(),
					isActive: $viewModel.showAttributions,
					label: { EmptyView() }
				)
			}
			.background(Color(.backgroundRegular).edgesIgnoringSafeArea(.all))
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
				.bold()
				.body()
				.foregroundColor(Color(.textRegular))
				.padding(.horizontal, length: .m)
				.padding(.vertical, length: .s)
			Spacer()
		}
		.background(Color(.backgroundSectionHeader))
		.listRowInsets(.empty)
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
					.foregroundColor(Color(.textRegular))
				Spacer()
				Text(selected.description)
					.body()
					.foregroundColor(Color(.textRegular))
			}
		})
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
				.body()
				.foregroundColor(Color(.textRegular))
		})
	}

	// MARK: Features

	#if DEBUG
	private var featureToggles: some View {
		ForEach(Feature.allCases, id: \.rawValue) { feature in
			Toggle(feature.rawValue, isOn: self.binding(for: feature))
				.foregroundColor(Color(.textRegular))
				.padding(.vertical, length: .xs)
		}
	}
	#endif

	// MARK: About

	private var viewSource: some View {
		Button(action: {
			self.viewModel.postViewAction(.viewSource)
		}, label: {
			HStack {
				Text("View source")
					.body()
					.foregroundColor(Color(.textRegular))
				Spacer()
				Image(uiImage: UIImage(systemName: "chevron.right")!)
					.resizable()
					.frame(width: 8, height: 12)
					.foregroundColor(Color(.textSecondary))
			}
		})
	}

	private var attributions: some View {
		Button(action: {
			self.viewModel.postViewAction(.viewAttributions)
		}, label: {
			HStack {
				Text("Attributions")
					.body()
					.foregroundColor(Color(.textRegular))
				Spacer()
				Image(uiImage: UIImage(systemName: "chevron.right")!)
					.resizable()
					.frame(width: 8, height: 12)
					.foregroundColor(Color(.textSecondary))
			}
		})
	}

	private var appInfo: some View {
		HStack {
			Spacer()
			VStack(alignment: .trailing, spacing: .xs) {
				Text(viewModel.appName)
					.body()
					.foregroundColor(Color(.textSecondary))
				Text(viewModel.appVersion)
					.body()
					.foregroundColor(Color(.textSecondary))
			}
		}
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

	private func binding(for preference: WritableKeyPath<Preferences, Bool>) -> Binding<Bool> {
		Binding(
			get: { self.preferencesBinding.wrappedValue[keyPath: preference] },
			set: { self.preferencesBinding.wrappedValue[keyPath: preference] = $0 }
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
