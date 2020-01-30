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
			.receive(on: DispatchQueue.main)
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

	init(url: URL?, placeholder: UIImage = UIImage()) {
		self.placeholder = placeholder
		self.imageFetcher = RemoteImageFetcher(url: url)
	}

	var body: some View {
		GeometryReader { geometry in
			return ZStack {
				if self.imageFetcher.image != nil {
					Image(uiImage: self.imageFetcher.image!)
						.resizable()
						.frame(width: geometry.size.width, height: geometry.size.height)
				} else {
					Image(uiImage: self.placeholder)
						.resizable()
						.frame(width: geometry.size.width, height: geometry.size.height)
				}
			}
		}
		.onAppear(perform: imageFetcher.fetch)
		.onDisappear(perform: imageFetcher.cancel)
	}
}

#if DEBUG
struct RemoteImagePreview: PreviewProvider {
	static var previews: some View {
		VStack {
			RemoteImage(url: nil, placeholder: UIImage(systemName: "xmark")!)
				.frame(width: 64, height: 64)
			RemoteImage(url: nil, placeholder: ImageAsset.joseph)
				.frame(width: 128, height: 128)
		}
	}
}
#endif
