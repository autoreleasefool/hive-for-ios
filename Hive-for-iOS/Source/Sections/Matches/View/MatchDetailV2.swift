//
//  MatchDetailV2.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI
import HiveEngine
import SwiftUIRefresh

struct MatchDetailV2: View {
	@Environment(\.presentationMode) private var presentationMode
	@Environment(\.toaster) private var toaster: Toaster
	@Environment(\.container) private var container: AppContainer

	@ObservedObject private var viewModel: MatchDetailViewModelV2

	init(id: Match.ID?, match: Loadable<Match> = .notLoaded) {
		self.viewModel = MatchDetailViewModelV2(id: id, match: match)
	}

	var body: some View {
		GeometryReader { geometry in
			NavigationLink(
				destination: HiveGame { self.presentationMode.wrappedValue.dismiss() },
				isActive: self.$viewModel.inGame,
				label: { EmptyView() }
			)

			self.content(geometry)
		}
		.navigationBarTitle(Text(viewModel.title), displayMode: .inline)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: exitButton, trailing: startButton)
		.onReceive(accountUpdate) { self.viewModel.account = $0 }
		.onReceive(viewModel.actions) { self.handleAction($0) }
		.popoverSheet(isPresented: $viewModel.exiting) {
			PopoverSheetConfig(
				title: "Leave match?",
				message: "Are you sure you want to leave this match?",
				buttons: [
					PopoverSheetConfig.ButtonConfig(title: "Leave", type: .destructive) {
						self.viewModel.exiting = false
						self.viewModel.postViewAction(.exitMatch)
					},
					PopoverSheetConfig.ButtonConfig(title: "Stay", type: .cancel) {
						self.viewModel.exiting = false
					},
				]
			)
		}
	}

	private func content(_ geometry: GeometryProxy) -> AnyView {
		switch viewModel.match {
		case .notLoaded: return AnyView(notLoadedView)
		case .loading(let match, _): return AnyView(loadedView(match, geometry))
		case .loaded(let match): return AnyView(loadedView(match, geometry))
		case .failed: return AnyView(failedView)
		}
	}

	// MARK: - Content

	private var notLoadedView: some View {
		Text("")
			.onAppear {
				if self.viewModel.matchId == nil {
					self.createNewMatch()
				} else {
					self.joinMatch()
				}
			}
	}

	private func loadedView(_ match: Match?, _ geometry: GeometryProxy) -> some View {
		ScrollView {
			if match == nil {
				HStack {
					Spacer()
					ActivityIndicator(isAnimating: true, style: .large)
					Spacer()
				}
				.padding(.top, length: .m)
				.frame(width: geometry.size.width)
			} else {
				VStack(spacing: .m) {
					self.playerSection(match: match!)
					Divider().background(Color(.divider))
					self.expansionSection
					Divider().background(Color(.divider))
					self.otherOptionsSection
				}
				.padding(.horizontal, length: .m)
				.padding(.top, length: .m)
				.frame(width: geometry.size.width)
			}
		}
		.pullToRefresh(isShowing: viewModel.isRefreshing) {
			self.loadMatchDetails()
		}
	}

	private var failedView: some View {
		EmptyView()
	}

	// MARK: Match Details

	private func playerSection(match: Match) -> some View {
		HStack(spacing: 0) {
			MatchUserSummary(
				match.host,
				isReady: self.viewModel.isPlayerReady(id: match.host?.id),
				iconSize: .l
			)
			Spacer()
			MatchUserSummary(
				match.opponent,
				isReady: self.viewModel.isPlayerReady(id: match.opponent?.id),
				alignment: .trailing,
				iconSize: .l
			)
		}
	}

	var expansionSection: some View {
		VStack(alignment: .leading) {
			Text("Expansions")
				.bold()
				.body()
				.foregroundColor(Color(.text))
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
			HStack(spacing: .l) {
				Spacer()
				ForEach(GameState.Option.expansions, id: \.rawValue) { option in
					self.expansionOption(for: option, enabled: self.viewModel.gameOptions.contains(option))
				}
				Spacer()
			}
		}
	}

	private func expansionOption(for option: GameState.Option, enabled: Bool) -> some View {
		Button(action: {
			self.viewModel.gameOptionEnabled(option: option).wrappedValue.toggle()
		}, label: {
			ZStack {
				Text(self.viewModel.name(forOption: option))
					.subtitle()
					.foregroundColor(
						enabled
							? Color(.primary)
							: Color(.textSecondary)
					)
				Hex()
					.stroke(
						enabled
							? Color(.primary)
							: Color(.textSecondary),
						lineWidth: CGFloat(5)
					)
					.squareImage(.l)
			}
		})
		.disabled(!viewModel.userIsHost)
	}

	private func optionSectionHeader(title: String) -> some View {
		Text(title)
			.bold()
			.body()
			.foregroundColor(Color(.text))
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
	}

	private var matchOptionsSection: some View {
		VStack(alignment: .leading) {
			self.optionSectionHeader(title: "Match options")
			ForEach(Match.Option.enabledOptions, id: \.rawValue) { option in
				Toggle(self.viewModel.name(forOption: option), isOn: self.viewModel.optionEnabled(option: option))
					.disabled(!self.viewModel.userIsHost)
					.foregroundColor(Color(.text))
			}
		}
	}

	private var otherOptionsSection: some View {
		VStack(alignment: .leading) {
			self.optionSectionHeader(title: "Other options")
			ForEach(GameState.Option.nonExpansions, id: \.rawValue) { option in
				Toggle(self.viewModel.name(forOption: option), isOn: self.viewModel.gameOptionEnabled(option: option))
					.disabled(!self.viewModel.userIsHost)
					.foregroundColor(Color(.text))
			}
		}
	}

	// MARK: Buttons

	private var exitButton: some View {
		Button(action: {
			self.viewModel.exiting = true
		}, label: {
			Text("Leave")
		})
	}

	private var startButton: some View {
		Button(action: {
			self.viewModel.postViewAction(.startMatch)
		}, label: {
			Text(viewModel.startButtonText)
		})
	}

	// MARK: - Actions

	private func handleAction(_ action: MatchDetailAction) {
		switch action {
		case .leftMatch:
			presentationMode.wrappedValue.dismiss()
		case .loadMatch:
			loadMatchDetails()
		case .presentLoaf(let loaf):
			toaster.loaf.send(loaf)
		}
	}

	private func joinMatch() {
		guard let id = viewModel.matchId else { return }
		container.interactors.matchInteractor
			.joinMatch(id: id, withAccount: container.account, match: $viewModel.match)
	}

	private func createNewMatch() {
		container.interactors.matchInteractor
			.createNewMatch(withAccount: container.account, match: $viewModel.match)
	}

	private func loadMatchDetails() {
		guard let id = viewModel.matchId else { return }
		container.interactors.matchInteractor
			.loadMatchDetails(id: id, withAccount: container.account, match: $viewModel.match)
	}

	// MARK: - Updates

	var accountUpdate: AnyPublisher<Loadable<AccountV2>, Never> {
		container.appState.updates(for: \.account)
	}
}
