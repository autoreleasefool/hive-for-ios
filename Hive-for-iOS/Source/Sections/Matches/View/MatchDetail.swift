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
			Spacer()
			MatchUserSummary(match.host, iconSize: .l)
			Spacer()
			MatchUserSummary(match.host, alignment: .trailing, iconSize: .l)
			Spacer()
		}
	}

	private func expansionSection(options: GameOptionData) -> some View {
		VStack(alignment: .leading) {
			Text("Expansions")
				.subtitle()
				.foregroundColor(Color(.text))
			ForEach(GameState.Option.expansions, id: \.rawValue) { option in
				Toggle(option.rawValue, isOn: self.viewModel.options.binding(for: option))
					.foregroundColor(Color(.text))
			}
		}
	}

	private func otherOptionsSection(options: GameOptionData) -> some View {
		VStack(alignment: .leading) {
			Text("Other options")
				.subtitle()
				.foregroundColor(Color(.text))
			ForEach(GameState.Option.nonExpansions, id: \.rawValue) { option in
				Toggle(option.rawValue, isOn: self.viewModel.options.binding(for: option))
					.foregroundColor(Color(.text))
			}
		}
	}

	var body: some View {
		List {
			if self.viewModel.match == nil {
				Text("Loading")
			} else {
				self.playerSection(match: self.viewModel.match!)
					.padding(.vertical, length: .m)
				self.expansionSection(options: self.viewModel.options)
				self.otherOptionsSection(options: self.viewModel.options)
			}
		}
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
		MatchDetail(viewModel: MatchDetailViewModel(match: Match.matches[0]))
	}
}
#endif
