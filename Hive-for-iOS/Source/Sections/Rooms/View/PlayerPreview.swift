//
//  PlayerPreview.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-26.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct PlayerPreview: View {
	enum Alignment {
		case leading, trailing
	}

	let player: HivePlayer?
	let textAlignment: Alignment
	let compact: Bool
	let iconSize: CGFloat

	init(_ player: HivePlayer?, alignment: Alignment = .leading, compact: Bool = false, iconSize: CGFloat = Metrics.Image.listIcon) {
		self.player = player
		self.textAlignment = alignment
		self.compact = compact
		self.iconSize = iconSize
	}

	var primaryText: String {
		guard let player = player else { return "N/A" }
		return compact ? player.formattedELO : player.name
	}

	var secondaryText: String {
		guard let player = player else { return "" }
		return compact ? "ELO" : "\(player.formattedELO) ELO"
	}

	var playerImage: some View {
		HexImage(url: player?.avatarUrl, placeholder: Assets.Image.joseph)
			.frame(width: iconSize, height: iconSize)
	}

	var playerDescription: some View {
		VStack(alignment: textAlignment == .leading ? .leading : .trailing) {
			Text(primaryText)
				.font(.system(size: Metrics.Text.body))
				.foregroundColor(Assets.Color.text.color)
				.frame(minWidth: 64, alignment: textAlignment == .leading ? .leading : .trailing)
			if player != nil {
				Text(secondaryText)
					.font(.system(size: Metrics.Text.caption))
					.foregroundColor(Assets.Color.textSecondary.color)
			}
		}
	}

	var body: some View {
		HStack(spacing: Metrics.Spacing.smaller) {
			if textAlignment == .leading {
				playerImage
				playerDescription
			} else {
				playerDescription
				playerImage
			}
		}
			.opacity(player == nil ? 0.7 : 1)
	}
}

#if DEBUG
struct PlayerPreviewPreview: PreviewProvider {
	static var previews: some View {
		VStack {
			PlayerPreview(HivePlayer.players[0])
			PlayerPreview(HivePlayer.players[0], iconSize: Metrics.Image.larger)
			PlayerPreview(HivePlayer.players[0], alignment: .trailing)
			PlayerPreview(HivePlayer.players[0], compact: true)
			PlayerPreview(nil)
			PlayerPreview(nil, iconSize: Metrics.Image.larger)
			PlayerPreview(nil, alignment: .trailing)
			PlayerPreview(nil, compact: true)
		}
			.background(Assets.Color.background.color)
	}
}
#endif
