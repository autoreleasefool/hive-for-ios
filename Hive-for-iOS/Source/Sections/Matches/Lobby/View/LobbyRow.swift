//
//  LobbyRow.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct LobbyRow: View {
	let match: Match

	private func optionsPreview(for options: Set<GameState.Option>) -> some View {
		HStack(spacing: .s) {
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
					? Color(.text)
					: Color(.textSecondary)
				)
			Hex()
				.stroke(
					enabled
						? Color(.primary)
						: Color(.primary).opacity(0.4),
					lineWidth: CGFloat(2)
				)
				.squareImage(.m)
		}
	}

	var body: some View {
		HStack(spacing: .m) {
			MatchUserSummary(match.host.preview)
			Spacer()
			optionsPreview(for: match.gameOptionSet)
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
struct LobbyRowPreview: PreviewProvider {
	static var previews: some View {
		LobbyRow(match: Match.matches[0])
			.background(Color(.background))
	}
}
#endif
