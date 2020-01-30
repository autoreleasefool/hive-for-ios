//
//  RoomView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct RoomRow: View {
	let room: Room

	private func optionsPreview(for options: Set<GameState.Options>) -> some View {
		HStack(spacing: Metrics.Spacing.s.rawValue) {
			ForEach(GameState.Options.expansions, id: \.rawValue) { option in
				self.optionPreview(for: option, enabled: options.contains(option))
			}
		}
	}

	private func optionPreview(for option: GameState.Options, enabled: Bool) -> some View {
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
			PlayerPreview(room.host, compact: true)
			PlayerPreview(room.opponent, compact: true)
			Spacer()
			optionsPreview(for: room.options)
		}
		.padding(.vertical, .m)
	}
}

private extension GameState.Options {
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
struct RoomRowPreview: PreviewProvider {
	static var previews: some View {
		RoomRow(room: Room.rooms[0])
			.background(Color(ColorAsset.background))
	}
}
#endif
