//
//  MatchUserSummary.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-26.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct MatchUserSummary: View {
	enum Alignment {
		case leading, trailing
	}

	let user: Match.User?
	let textAlignment: Alignment
	let compact: Bool
	let iconSize: Metrics.Image

	init(_ user: Match.User?, alignment: Alignment = .leading, compact: Bool = false, iconSize: Metrics.Image = .m) {
		self.user = user
		self.textAlignment = alignment
		self.compact = compact
		self.iconSize = iconSize
	}

	var primaryText: String {
		guard let user = user else { return "N/A" }
		return compact ? user.formattedELO : user.displayName
	}

	var secondaryText: String {
		guard let user = user else { return "" }
		return compact ? "ELO" : "\(user.formattedELO) ELO"
	}

	var userImage: some View {
		HexImage(url: user?.avatarURL, placeholder: ImageAsset.borderlessGlyph)
			.placeholderTint(.primary)
			.squareImage(iconSize)
	}

	var userDescription: some View {
		VStack(alignment: textAlignment == .leading ? .leading : .trailing) {
			Text(primaryText)
				.body()
				.foregroundColor(Color(.text))
				.frame(minWidth: 64, alignment: textAlignment == .leading ? .leading : .trailing)
			if user != nil {
				Text(secondaryText)
					.caption()
					.foregroundColor(Color(.textSecondary))
			}
		}
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
}

#if DEBUG
struct MatchUserSummaryPreview: PreviewProvider {
	static var previews: some View {
		VStack {
			MatchUserSummary(Match.User.users[0])
			MatchUserSummary(Match.User.users[0], iconSize: .l)
			MatchUserSummary(Match.User.users[0], alignment: .trailing)
			MatchUserSummary(Match.User.users[0], compact: true)
			MatchUserSummary(nil)
			MatchUserSummary(nil, iconSize: .l)
			MatchUserSummary(nil, alignment: .trailing)
			MatchUserSummary(nil, compact: true)
		}
		.background(Color(.background))
	}
}
#endif
