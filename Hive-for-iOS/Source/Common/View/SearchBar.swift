//
//  SearchBar.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-10-19.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct SearchBar: View {
	private let icon: UIImage?
	private let placeholder: String

	@Binding private var text: String

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
					.foregroundColor(Color(.textContrasting))
					.squareImage(.s)
			}

			ZStack(alignment: .leading) {
				if text.isEmpty { Text(placeholder).foregroundColor(Color(.textContrastingSecondary)) }
				TextField("", text: $text)
					.foregroundColor(Color(.textContrasting))
			}

			if !text.isEmpty {
				Image(systemName: "xmark.circle.fill")
					.resizable()
					.foregroundColor(Color(.textContrasting))
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
		.background(Color(.textField))
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
