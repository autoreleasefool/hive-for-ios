//
//  ProfileView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

struct ProfileView: View {
	@Environment(\.container) private var container

	@StateObject private var viewModel: ProfileViewModel

	init(id: User.ID? = nil, user: Loadable<User> = .notLoaded) {
		_viewModel = StateObject(wrappedValue: ProfileViewModel(id: id, user: user))
	}

	var body: some View {
		content
			.modifier(ProfileTitleModifier(title: viewModel.title, isEnabled: viewModel.isTitleEnabled))
			.onReceive(viewModel.actionsPublisher) { handleAction($0) }
			.listensToAppStateChanges([.accountChanged]) { reason in
				switch reason {
				case .accountChanged:
					viewModel.postViewAction(.loadProfile)
				case .toggledFeature:
					break
				}
			}
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.user {
		case .notLoaded: notLoadedView
		case .loading: loadingView
		case .loaded(let user): loadedView(user)
		case .failed(let error): failedView(error)
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.onAppear { viewModel.postViewAction(.onAppear) }
	}

	private var loadingView: some View {
		ProgressView()
	}

	private func loadedView(_ user: User) -> some View {
		List {
			Section(header: Text("")) {
				VStack(alignment: .center, spacing: 0) {
					HexImage(url: user.avatarUrl, placeholder: ImageAsset.borderlessGlyph, stroke: .highlightPrimary)
						.placeholderTint(.highlightPrimary)
						.squareImage(.xl)
						.padding(.vertical, Metrics.Spacing.m.rawValue)

					Text(user.displayName)
						.font(.headline)
						.foregroundColor(Color(.textRegular))
						.frame(maxWidth: .infinity)
						.padding(.bottom, Metrics.Spacing.s.rawValue)

					Text("\(user.elo) ELO")
						.font(.subheadline)
						.foregroundColor(Color(.textSecondary))
						.frame(maxWidth: .infinity)
				}
			}

			Section(header: Text("Most recent matches")) {
				if !user.pastMatches.isEmpty {
					ForEach(user.pastMatches.prefix(3)) { match in
						HistoryRow(match: match, withLastMove: false)
					}
				} else {
					Text("Not available")
						.font(.subheadline)
						.foregroundColor(Color(.textSecondary))
						.frame(maxWidth: .infinity)
				}
			}
		}
		.listStyle(InsetGroupedListStyle())
	}

	private func failedView(_ error: Error) -> some View {
		failedState(error)
	}
}

// MARK: - EmptyState

extension ProfileView {
	private func failedState(_ error: Error) -> some View {
		EmptyState(
			header: "An error occurred",
			message: viewModel.id == nil
				? "We can't fetch your profile right now.\n\(viewModel.errorMessage(from: error))"
				: "We can't fetch this profile right now.\n\(viewModel.errorMessage(from: error))",
			action: .init(text: "Refresh") {
				viewModel.postViewAction(.loadProfile)
			}
		)
	}
}

// MARK: - Actions

extension ProfileView {
	private func handleAction(_ action: ProfileAction) {
		switch action {
		case .loadProfile:
			loadProfile()
		}
	}

	private func loadProfile() {
		if let id = viewModel.id {
			container.interactors.userInteractor
				.loadDetails(id: id, user: $viewModel.user)
		} else {
			container.interactors.userInteractor
				.loadProfile(user: $viewModel.user)
		}
	}
}

// MARK: Title modifier

private struct ProfileTitleModifier: ViewModifier {
	let title: String
	let isEnabled: Bool

	@ViewBuilder
	func body(content: Content) -> some View {
		if isEnabled {
			content
				.navigationBarTitle(title)
		} else {
			content
		}
	}
}

// MARK: - Preview

#if DEBUG
struct ProfilePreview: PreviewProvider {
	static var previews: some View {
		ProfileView(user: .loaded(User.users[0]))
	}
}
#endif
