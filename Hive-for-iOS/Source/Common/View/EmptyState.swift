//
//  EmptyState.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-10.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct EmptyState: View {
	private let image: UIImage?
	private let headerText: String
	private let messageText: String
	private let action: Action?

	init(header: String, message: String, image: UIImage? = nil, action: Action? = nil) {
		self.image = image
		self.headerText = header
		self.messageText = message
		self.action = action
	}

	var body: some View {
		GeometryReader { geometry in
			VStack(spacing: 0) {
				Spacer()

				if image != nil {
					emptyStateImage(image!, geometry)
						.padding(.horizontal)
				}

				VStack {
					header
					message
				}
				.padding()

				if action != nil {
					actionButton(action: action!)
						.padding(.horizontal)
				}
				Spacer()
			}
			.frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
		}
		.background(Color(.backgroundRegular))
	}

	// MARK: EmptyState

	private func emptyStateImage(_ image: UIImage, _ geometry: GeometryProxy) -> some View {
		Image(uiImage: image)
			.resizable()
			.scaledToFit()
			.frame(maxWidth: geometry.size.width, alignment: .center)
			.padding(.horizontal)
	}

	private var header: some View {
		Text(headerText)
			.font(.headline)
			.foregroundColor(Color(.textRegular))
			.multilineTextAlignment(.center)
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
	}

	private var message: some View {
		Text(messageText)
			.font(.body)
			.foregroundColor(Color(.textRegular))
			.multilineTextAlignment(.center)
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
	}

	private func actionButton(action: Action) -> some View {
		PrimaryButton(action.text) { action.callback() }
	}
}

extension EmptyState {
	struct Action {
		let text: String
		let callback: () -> Void
	}
}

// MARK: - Preview

#if DEBUG
struct EmptyStatePreview: PreviewProvider {
	static var previews: some View {
		EmptyState(
			header: "No matches found",
			message: "Try playing a match, and when you're finished, you'll be able to find it here. " +
				"You'll also be able to see your incomplete matches.",
			image: ImageAsset.joseph,
			action: EmptyState.Action(text: "Refresh", callback: { })
		)
	}
}
#endif
