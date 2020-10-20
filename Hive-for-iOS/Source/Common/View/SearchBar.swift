//
//  SearchBar.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-10-19.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct SearchBar: View {
	@Environment(\.colorScheme) var colorScheme

	private let icon: UIImage?
	private let placeholder: String

	@Binding private var text: String

	private var backgroundColor: Color {
		colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6)
	}

	init(_ placeholder: String = "Search...", icon: String? = nil, text: Binding<String>) {
		self.placeholder = placeholder
		self._text = text
		if let icon = icon {
			self.icon = UIImage(systemName: icon)
		} else {
			self.icon = nil
		}
	}

	@ViewBuilder
	var body: some View {
		HStack {
			if let icon = icon {
				Image(uiImage: icon)
					.resizable()
					.renderingMode(.template)
					.foregroundColor(Color(.textRegular))
					.squareImage(.s)
			}

			TextField(placeholder, text: $text)

			if !text.isEmpty {
				Image(systemName: "xmark.circle.fill")
					.resizable()
					.squareImage(.s)
					.padding(2)
					.onTapGesture {
						withAnimation {
							text = ""
						}
					}
			}
		}
		.padding(Metrics.Spacing.s.rawValue)
		.background(backgroundColor)
		.cornerRadius(Metrics.CornerRadius.s.rawValue)
		.padding(.vertical, Metrics.Spacing.s.rawValue)
	}
}

#if DEBUG
struct SearchBarPreview: PreviewProvider {
	static var previews: some View {
		SearchBar("Search", icon: "person", text: .constant(""))
			.preferredColorScheme(.light)
	}
}
#endif
