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
	private static let previewableOptions: [GameState.Options] = [.ladyBug, .mosquito, .pillBug]

	let room: Room

	private func playerPreview(for player: HivePlayer?) -> some View {
		HStack(spacing: Metrics.Spacing.smaller) {
			HexImage(url: player?.avatarUrl, placeholder: Assets.Image.joseph)
				.frame(width: Metrics.Image.listIcon, height: Metrics.Image.listIcon)
			VStack(alignment: .leading) {
				Text(player?.formattedELO ?? "N/A")
					.font(.system(size: Metrics.Text.body))
					.foregroundColor(Assets.Color.text.color)
					.frame(minWidth: 64, alignment: .leading)
				Text("ELO")
					.font(.system(size: Metrics.Text.caption))
					.foregroundColor(Assets.Color.textSecondary.color)
			}
		}
	}

	private func optionsPreview(for options: Set<GameState.Options>) -> some View {
		HStack(spacing: Metrics.Spacing.smaller) {
			ForEach(RoomRow.previewableOptions, id: \.rawValue) { option in
				self.optionPreview(for: option, enabled: options.contains(option))
			}
		}
	}

	private func optionPreview(for option: GameState.Options, enabled: Bool) -> some View {
		ZStack {
			Text(option.preview ?? "")
				.font(.system(size: Metrics.Text.caption))
				.foregroundColor(enabled
					? Assets.Color.text.color
					: Assets.Color.textSecondary.color
				)
			Hex()
				.stroke(
					enabled
						? Assets.Color.primary.color
						: Assets.Color.primary.withAlphaComponent(0.4).color,
					lineWidth: CGFloat(2)
				)
				.frame(width: 24, height: 24)
		}
	}

	var body: some View {
		HStack(spacing: Metrics.Spacing.standard) {
			playerPreview(for: room.host)
			playerPreview(for: room.opponent)
			Spacer()
			optionsPreview(for: room.options)
		}
		.padding(EdgeInsets(vertical: Metrics.Spacing.standard))
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
			.background(Assets.Color.background.color)
	}
}
#endif
