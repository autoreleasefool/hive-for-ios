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
	let iconSize: Metrics.Image

	init(_ player: HivePlayer?, alignment: Alignment = .leading, compact: Bool = false, iconSize: Metrics.Image = .standard) {
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
		HexImage(url: player?.avatarUrl, placeholder: ImageAsset.joseph)
			.imageFrame(width: iconSize, height: iconSize)
	}

	var playerDescription: some View {
		VStack(alignment: textAlignment == .leading ? .leading : .trailing) {
			Text(primaryText)
				.body()
				.foregroundColor(Color(ColorAsset.text))
				.frame(minWidth: 64, alignment: textAlignment == .leading ? .leading : .trailing)
			if player != nil {
				Text(secondaryText)
					.caption()
					.foregroundColor(Color(ColorAsset.textSecondary))
			}
		}
	}

	var body: some View {
		HStack(spacing: Metrics.Spacing.small.rawValue) {
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
			PlayerPreview(HivePlayer.players[0], iconSize: .large)
			PlayerPreview(HivePlayer.players[0], alignment: .trailing)
			PlayerPreview(HivePlayer.players[0], compact: true)
			PlayerPreview(nil)
			PlayerPreview(nil, iconSize: .large)
			PlayerPreview(nil, alignment: .trailing)
			PlayerPreview(nil, compact: true)
		}
		.background(Color(ColorAsset.background))
	}
}
#endif
