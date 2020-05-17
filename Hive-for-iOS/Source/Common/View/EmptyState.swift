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
	private let onRefresh: (() -> Void)?

	init(header: String, message: String, image: UIImage? = nil, onRefresh: (() -> Void)? = nil) {
		self.image = image
		self.headerText = header
		self.messageText = message
		self.onRefresh = onRefresh
	}

	var body: some View {
		GeometryReader { geometry in
			VStack(spacing: .m) {
				Spacer()

				if self.image != nil {
					self.emptyStateImage(self.image!, geometry)
				}

				VStack(spacing: .s) {
					self.header
					self.message
				}
				.padding(.horizontal, length: .m)

				if self.onRefresh != nil {
					self.refreshButton
						.padding(.horizontal, length: .m)
				}
				Spacer()
			}
			.frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
		}
	}

	// MARK: EmptyState

	private func emptyStateImage(_ image: UIImage, _ geometry: GeometryProxy) -> some View {
		Image(uiImage: image)
			.resizable()
			.scaledToFit()
			.frame(maxWidth: geometry.size.width, alignment: .center)
	}

	private var header: some View {
		Text(headerText)
			.subtitle()
			.multilineTextAlignment(.center)
			.foregroundColor(Color(.text))
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
	}

	private var message: some View {
		Text(messageText)
			.body()
			.multilineTextAlignment(.center)
			.foregroundColor(Color(.textSecondary))
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
	}

	private var refreshButton: some View {
		Button(action: {
			self.onRefresh?()
		}, label: {
			Text("Refresh")
				.body()
				.foregroundColor(Color(.text))
				.padding(.vertical, length: .m)
				.frame(minWidth: 0, maxWidth: .infinity)
				.background(
					RoundedRectangle(cornerRadius: .s)
						.fill(Color(.primary))
				)
		})
	}
}

#if DEBUG
struct EmptyStatePreview: PreviewProvider {
	static var previews: some View {
		EmptyState(
			header: "No matches found",
			message: "Try playing a match, and when you're finished, you'll be able to find it here. " +
				"You'll also be able to see your incomplete matches.",
			image: ImageAsset.joseph
		) { }
			.background(Color(.background).edgesIgnoringSafeArea(.all))
	}
}
#endif
