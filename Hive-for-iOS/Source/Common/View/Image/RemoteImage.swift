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

	init(url: URL?) {
		self.url = url
	}

	deinit {
		cancel()
	}

	func fetch() {
		cancellable = ImageLoader
			.shared
			.fetch(url: url)
			.receive(on: RunLoop.main)
			.sink(
				receiveCompletion: { _ in },
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
	@ObservedObject private var imageFetcher: RemoteImageFetcher
	private let placeholder: UIImage
	private var placeholderTint: ColorAsset?

	init(url: URL?, placeholder: UIImage = UIImage()) {
		self.placeholder = placeholder
		self.imageFetcher = RemoteImageFetcher(url: url)
		self.imageFetcher.fetch()
	}

	var body: some View {
		GeometryReader { geometry in
			if self.imageFetcher.image != nil {
				Image(uiImage: self.imageFetcher.image!)
					.resizable()
					.scaledToFit()
					.frame(width: geometry.size.width, height: geometry.size.height)

			} else {
				Image(uiImage: self.placeholder)
					.renderingMode(self.placeholderTint != nil ? .template : .original)
					.resizable()
					.scaledToFit()
					.foregroundColor(self.placeholderTint != nil ? Color(self.placeholderTint!) : nil)
					.frame(width: geometry.size.width, height: geometry.size.height)
			}
		}
		.onDisappear(perform: imageFetcher.cancel)
	}

	func placeholderTint(_ asset: ColorAsset?) -> Self {
		var remoteImage = self
		remoteImage.placeholderTint = asset
		return remoteImage
	}
}

#if DEBUG
struct RemoteImagePreview: PreviewProvider {
	static var previews: some View {
		VStack {
			RemoteImage(url: nil, placeholder: ImageAsset.Icon.handFilled)
				.placeholderTint(.primary)
				.squareImage(.xl)
			RemoteImage(url: nil, placeholder: ImageAsset.joseph)
				.imageFrame(width: .l, height: .m)
		}
	}
}
#endif
