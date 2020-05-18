//
//  MatchDetail.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct MatchDetail: View {
	private let match: Match
	private let matchOptions: Set<Match.Option>
	private let gameOptions: Set<GameState.Option>

	init(match: Match) {
		self.match = match
		self.matchOptions = match.optionSet
		self.gameOptions = match.gameOptionSet
	}

	var body: some View {
		VStack(spacing: .m) {
			self.playerSection
			Divider().background(Color(.divider))
			self.expansionSection
		}
		.padding(.all, length: .m)
	}

	// MARK: Match Details

	private var playerSection: some View {
		HStack(spacing: .xs) {
			MatchUserSummary(
				match.host?.preview,
				highlight: match.winner?.id == match.host?.id,
				iconSize: .l
			)
			Spacer()
			MatchUserSummary(
				match.opponent?.preview,
				highlight: match.winner?.id == match.opponent?.id,
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
					self.expansionOption(for: option, enabled: self.gameOptions.contains(option))
				}
				Spacer()
			}
		}
	}

	private func expansionOption(for option: GameState.Option, enabled: Bool) -> some View {
		ZStack {
			Text(name(forOption: option))
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
	}
}

// MARK: - Strings

extension MatchDetail {
	func name(forOption option: Match.Option) -> String {
		switch option {
		case .asyncPlay: return "Asynchronous play"
		case .hostIsWhite: return "\(match.host?.displayName ?? "Host") is white"
		}
	}

	func name(forOption option: GameState.Option) -> String {
		return option.preview ?? option.displayName
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
		return MatchDetail(match: Match.matches[0])
	}
}
#endif
