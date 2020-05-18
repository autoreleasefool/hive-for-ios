//
//  MatchUserSummary.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-26.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct MatchUserSummary: View {
	struct UserPreview {
		let displayName: String
		let elo: Int
		let avatarURL: URL?
	}

	enum Alignment {
		case leading, trailing
	}

	let user: UserPreview?
	let highlight: Bool
	let textAlignment: Alignment
	let iconSize: Metrics.Image

	init(
		_ user: UserPreview?,
		highlight: Bool = false,
		alignment: Alignment = .leading,
		iconSize: Metrics.Image = .m
	) {
		self.user = user
		self.highlight = highlight
		self.textAlignment = alignment
		self.iconSize = iconSize
	}

	var body: some View {
		HStack(spacing: .s) {
			if textAlignment == .leading {
				userImage
				userDescription
			} else {
				userDescription
				userImage
			}
		}
		.opacity(user == nil ? 0.7 : 1)
	}

	var primaryText: String {
		user?.displayName ?? "N/A"
	}

	var secondaryText: String {
		guard let user = user else { return "" }
		return "\(user.elo) ELO"
	}

	var userImage: some View {
		let stroke: ColorAsset = user != nil && highlight ? .success : .primary
		return HexImage(url: user?.avatarURL, placeholder: ImageAsset.borderlessGlyph, stroke: stroke)
			.placeholderTint(.primary)
			.squareImage(iconSize)
	}

	var userDescription: some View {
		VStack(alignment: textAlignment == .leading ? .leading : .trailing) {
			Text(primaryText)
				.body()
				.foregroundColor(Color(.text))
				.multilineTextAlignment(textAlignment == .leading ? .leading : .trailing)
				.frame(minWidth: 64, alignment: textAlignment == .leading ? .leading : .trailing)
			if user != nil {
				Text(secondaryText)
					.caption()
					.foregroundColor(Color(.textSecondary))
					.frame(minWidth: 64, alignment: textAlignment == .leading ? .leading : .trailing)
			}
		}
	}
}

extension Match.User {
	var preview: MatchUserSummary.UserPreview {
		MatchUserSummary.UserPreview(displayName: displayName, elo: elo, avatarURL: avatarURL)
	}
}

extension User {
	var preview: MatchUserSummary.UserPreview {
		MatchUserSummary.UserPreview(displayName: displayName, elo: elo, avatarURL: avatarUrl)
	}
}

#if DEBUG
struct MatchUserSummaryPreview: PreviewProvider {
	static var previews: some View {
		VStack(spacing: .m) {
			MatchUserSummary(Match.User.users[0].preview)
				.border(Color(.highlight), width: 1)
			MatchUserSummary(Match.User.users[0].preview, highlight: true)
				.border(Color(.highlight), width: 1)
			MatchUserSummary(Match.User.users[0].preview, iconSize: .l)
				.border(Color(.highlight), width: 1)
			MatchUserSummary(Match.User.users[0].preview, alignment: .trailing)
				.border(Color(.highlight), width: 1)
			MatchUserSummary(nil)
				.border(Color(.highlight), width: 1)
			MatchUserSummary(nil, highlight: true)
				.border(Color(.highlight), width: 1)
			MatchUserSummary(nil, iconSize: .l)
				.border(Color(.highlight), width: 1)
			MatchUserSummary(nil, alignment: .trailing)
				.border(Color(.highlight), width: 1)

			HStack(spacing: .xs) {
				MatchUserSummary(Match.User.users[0].preview, iconSize: .l)
					.border(Color(.highlight), width: 1)
				Spacer()
				MatchUserSummary(Match.User.users[1].preview, alignment: .trailing, iconSize: .l)
					.border(Color(.highlight), width: 1)
			}
		}
		.frame(width: UIScreen.main.bounds.width)
		.background(Color(.background))
	}
}
#endif
