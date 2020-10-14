//
//  LoadableImage.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//  Source:

import SwiftUI
import Combine

private class RemoteImageFetcher: ObservableObject {
	@Published private(set) var image: UIImage?

	private let url: URL?
	private var cancellable: AnyCancellable?
	private var networkRequestInProgress = false

	init(url: URL?) {
		self.url = url
	}

	deinit {
		cancel()
	}

	func fetch() {
		guard !networkRequestInProgress else { return }
		networkRequestInProgress = true
		cancellable = ImageLoader
			.shared
			.fetch(url: url)
			.receive(on: RunLoop.main)
			.sink(
				receiveCompletion: { [weak self] _ in self?.networkRequestInProgress = false },
				receiveValue: { [weak self] result in
					guard self?.url == result.0 else { return }
					self?.image = result.1
				}
			)
	}

	func cancel() {
		cancellable?.cancel()
	}
}

struct RemoteImage: View {
	@StateObject private var imageFetcher: RemoteImageFetcher
	private let placeholder: UIImage
	private var placeholderTint: ColorAsset?

	init(url: URL?, placeholder: UIImage = UIImage()) {
		self.placeholder = placeholder
		self._imageFetcher = StateObject(wrappedValue: RemoteImageFetcher(url: url))
	}

	var body: some View {
		GeometryReader { geometry in
			if imageFetcher.image != nil {
				Image(uiImage: imageFetcher.image!)
					.resizable()
					.scaledToFit()
					.frame(width: geometry.size.width, height: geometry.size.height)
			} else {
				Image(uiImage: placeholder)
					.renderingMode(placeholderTint != nil ? .template : .original)
					.resizable()
					.scaledToFit()
					.foregroundColor(placeholderTint != nil ? Color(placeholderTint!) : nil)
					.frame(width: geometry.size.width, height: geometry.size.height)
			}
		}
		.onAppear { imageFetcher.fetch() }
		.onDisappear { imageFetcher.cancel() }
	}

	func placeholderTint(_ asset: ColorAsset?) -> Self {
		var remoteImage = self
		remoteImage.placeholderTint = asset
		return remoteImage
	}
}

// MARK: - Preview

#if DEBUG
struct RemoteImagePreview: PreviewProvider {
	static var previews: some View {
		VStack {
			RemoteImage(url: nil, placeholder: ImageAsset.Icon.handFilled)
				.placeholderTint(.highlightPrimary)
				.squareImage(.xl)
			RemoteImage(url: nil, placeholder: ImageAsset.joseph)
				.imageFrame(width: .l, height: .m)
		}
	}
}
#endif
