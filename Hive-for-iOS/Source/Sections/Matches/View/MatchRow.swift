//
//  MatchRow.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct MatchRow: View {
	let match: Match

	private func optionsPreview(for options: Set<GameState.Option>) -> some View {
		HStack(spacing: Metrics.Spacing.s.rawValue) {
			ForEach(GameState.Option.expansions, id: \.rawValue) { option in
				self.optionPreview(for: option, enabled: options.contains(option))
			}
		}
	}

	private func optionPreview(for option: GameState.Option, enabled: Bool) -> some View {
		ZStack {
			Text(option.preview ?? "")
				.caption()
				.foregroundColor(enabled
					? Color(ColorAsset.text)
					: Color(ColorAsset.textSecondary)
				)
			Hex()
				.stroke(
					enabled
						? Color(ColorAsset.primary)
						: Color(ColorAsset.primary).opacity(0.4),
					lineWidth: CGFloat(2)
				)
				.squareImage(.m)
		}
	}

	var body: some View {
		HStack(spacing: Metrics.Spacing.m.rawValue) {
			MatchUserSummary(match.host, compact: true)
			MatchUserSummary(match.opponent, compact: true)
			Spacer()
			optionsPreview(for: match.gameOptions)
		}
		.padding(.vertical, length: .m)
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
struct MatchRowPreview: PreviewProvider {
	static var previews: some View {
		MatchRow(match: Match.matches[0])
			.background(Color(ColorAsset.background))
	}
}
#endif
