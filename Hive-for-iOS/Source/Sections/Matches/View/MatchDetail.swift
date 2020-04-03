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
	@ObservedObject private var viewModel: MatchDetailViewModel

	init(viewModel: MatchDetailViewModel) {
		self.viewModel = viewModel
	}

	var startButton: some View {
		NavigationLink(destination: HiveGame(state: self.viewModel.gameState)) {
			Text("Start")
		}
	}

	private func playerSection(match: Match) -> some View {
		HStack(spacing: 0) {
			MatchUserSummary(match.host, iconSize: .l)
			Spacer()
			MatchUserSummary(match.opponent, alignment: .trailing, iconSize: .l)
		}
	}

	private func expansionSection(options: GameOptionData) -> some View {
		VStack(alignment: .leading) {
			Text("Expansions")
				.bold()
				.body()
				.foregroundColor(Color(.text))
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
			HStack(spacing: .l) {
				Spacer()
				ForEach(GameState.Option.expansions, id: \.rawValue) { option in
					self.optionPreview(for: option, enabled: options.options.contains(option))
				}
				Spacer()
			}
		}
	}

	private func optionPreview(for option: GameState.Option, enabled: Bool) -> some View {
		Button(action: {
			self.viewModel.options.binding(for: option).wrappedValue.toggle()
		}, label: {
			ZStack {
				Text(option.preview ?? "")
					.subtitle()
					.foregroundColor(enabled
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
	}

	private func otherOptionsSection(options: GameOptionData) -> some View {
		VStack(alignment: .leading) {
			Text("Other options")
				.bold()
				.body()
				.foregroundColor(Color(.text))
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
			ForEach(GameState.Option.nonExpansions, id: \.rawValue) { option in
				Toggle(option.rawValue, isOn: self.viewModel.options.binding(for: option))
					.foregroundColor(Color(.text))
			}
		}
	}

	var body: some View {
		ScrollView {
			if self.viewModel.match == nil {
				Text("Loading")
			} else {
				VStack(spacing: .m) {
					self.playerSection(match: self.viewModel.match!)
					Divider().background(Color(.divider))
					self.expansionSection(options: self.viewModel.options)
					Divider().background(Color(.divider))
					self.otherOptionsSection(options: self.viewModel.options)
				}
			}
		}
		.padding(.horizontal, length: .m)
		.navigationBarTitle(Text("Match \(viewModel.matchId)"), displayMode: .inline)
		.navigationBarItems(trailing: startButton)
		.onAppear { self.viewModel.postViewAction(.onAppear) }
		.onDisappear { self.viewModel.postViewAction(.onDisappear) }
		.loaf(self.$viewModel.errorLoaf)
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
		MatchDetail(viewModel: MatchDetailViewModel(match: Match.matches[1]))
			.background(Color(.background).edgesIgnoringSafeArea(.all))
	}
}
#endif
