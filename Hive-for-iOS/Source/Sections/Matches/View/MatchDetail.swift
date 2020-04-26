//
//  MatchDetail.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct MatchDetail: View {
	@Environment(\.presentationMode) var presentationMode
	@Environment(\.toaster) private var toaster: Toaster
	@EnvironmentObject private var account: Account
	@EnvironmentObject private var api: HiveAPI

	@ObservedObject private var viewModel: MatchDetailViewModel

	@State private var inGame: Bool = false
	@State private var exiting: Bool = false
	@State private var refreshing: Bool = false

	init(viewModel: MatchDetailViewModel) {
		self.viewModel = viewModel
	}

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
				Text(option.preview ?? "")
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

	private var exitButton: some View {
		Button(action: {
			self.exiting = true
		}, label: {
			Text("Leave")
		})
	}

	private var startButton: some View {
		Button(action: {
			self.viewModel.postViewAction(.startGame)
		}, label: {
			Text(viewModel.startButtonText)
		})
	}

	var body: some View {
		GeometryReader { geometry in
			NavigationLink(
				destination: HiveGame { self.presentationMode.wrappedValue.dismiss() }
					.environmentObject(self.viewModel.gameViewModel),
				isActive: self.$inGame,
				label: { EmptyView() }
			)

			if self.viewModel.match == nil {
				HStack {
					Spacer()
					ActivityIndicator(isAnimating: true, style: .whiteLarge)
					Spacer()
				}
				.padding(.top, length: .m)
				.frame(width: geometry.size.width)
			} else {
				ScrollView {
					VStack(spacing: .m) {
						self.playerSection(match: self.viewModel.match!)
						Divider().background(Color(.divider))
						self.expansionSection
						Divider().background(Color(.divider))
						self.otherOptionsSection
					}
					.padding(.horizontal, length: .m)
					.padding(.top, length: .m)
					.frame(width: geometry.size.width)
				}
				.pullToRefresh(isShowing: self.$refreshing) {
					self.viewModel.postViewAction(.refreshMatchDetails)
				}
			}
		}
		.background(Color(.background).edgesIgnoringSafeArea(.all))
		.navigationBarTitle(Text(viewModel.navigationBarTitle), displayMode: .inline)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: exitButton, trailing: startButton)
		.onAppear {
			self.viewModel.setAccount(to: self.account)
			self.viewModel.setAPI(to: self.api)
			self.viewModel.postViewAction(.onAppear)
		}
		.onDisappear {self.viewModel.postViewAction(.onDisappear) }
		.onReceive(self.viewModel.beginGame) { self.inGame = true }
		.onReceive(self.viewModel.breadBox) { self.toaster.loaf.send($0) }
		.onReceive(self.viewModel.refreshComplete) { self.refreshing = false }
		.onReceive(self.viewModel.leavingMatch) {
			self.presentationMode.wrappedValue.dismiss()
		}
		.popoverSheet(isPresented: self.$exiting) {
			PopoverSheetConfig(
				title: "Leave match?",
				message: "Are you sure you want to leave this match?",
				buttons: [
					PopoverSheetConfig.ButtonConfig(title: "Leave", type: .destructive) {
						self.exiting = false
						self.viewModel.postViewAction(.exitGame)
					},
					PopoverSheetConfig.ButtonConfig(title: "Stay", type: .cancel) {
						self.exiting = false
					},
				]
			)
		}
	}
}

private extension GameState.Option {
	var preview: String? {
		switch self {
		case .mosquito: return "M"
		case .ladyBug: return "L"
		case .pillBug: return "P"
		default: return nil
		}
	}
}

#if DEBUG
struct MatchDetailPreview: PreviewProvider {
	static var previews: some View {
		let account = Account()
		let api = HiveAPI(account: account)
		let viewModel = MatchDetailViewModel(match: Match.matches[0])

		return MatchDetail(viewModel: viewModel)
			.environmentObject(account)
			.environmentObject(api)
			.background(Color(.background).edgesIgnoringSafeArea(.all))
	}
}
#endif
