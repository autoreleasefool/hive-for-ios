//
//  UserPreview.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-26.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct UserPreview: View {
	struct UserSummary {
		let displayName: String
		let elo: Int
		let avatarURL: URL?
	}

	enum Alignment {
		case leading, trailing
	}

	let user: UserSummary?
	let highlight: Bool
	let textAlignment: Alignment
	let iconSize: Metrics.Image

	init(
		_ user: UserSummary?,
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
	var summary: UserPreview.UserSummary {
		UserPreview.UserSummary(displayName: displayName, elo: elo, avatarURL: avatarURL)
	}
}

extension User {
	var summary: UserPreview.UserSummary {
		UserPreview.UserSummary(displayName: displayName, elo: elo, avatarURL: avatarUrl)
	}
}

#if DEBUG
struct UserPreviewPreview: PreviewProvider {
	static var previews: some View {
		VStack(spacing: .m) {
			UserPreview(Match.User.users[0].summary)
				.border(Color(.highlight), width: 1)
			UserPreview(Match.User.users[0].summary, highlight: true)
				.border(Color(.highlight), width: 1)
			UserPreview(Match.User.users[0].summary, iconSize: .l)
				.border(Color(.highlight), width: 1)
			UserPreview(Match.User.users[0].summary, alignment: .trailing)
				.border(Color(.highlight), width: 1)
			UserPreview(nil)
				.border(Color(.highlight), width: 1)
			UserPreview(nil, highlight: true)
				.border(Color(.highlight), width: 1)
			UserPreview(nil, iconSize: .l)
				.border(Color(.highlight), width: 1)
			UserPreview(nil, alignment: .trailing)
				.border(Color(.highlight), width: 1)

			HStack(spacing: .xs) {
				UserPreview(Match.User.users[0].summary, iconSize: .l)
					.border(Color(.highlight), width: 1)
				Spacer()
				UserPreview(Match.User.users[1].summary, alignment: .trailing, iconSize: .l)
					.border(Color(.highlight), width: 1)
			}
		}
		.frame(width: UIScreen.main.bounds.width)
		.background(Color(.background))
	}
}
#endif
