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
	@State private var placeholder: UIImage?

	init(url: URL?) {
		self.imageFetcher = RemoteImageFetcher(url: url)
	}

	var body: some View {
		return ZStack {
			if imageFetcher.image != nil {
				Image(uiImage: imageFetcher.image!)
					.resizable()
			} else if placeholder != nil {
				Image(uiImage: placeholder!)
					.resizable()
			}
		}
		.onAppear(perform: imageFetcher.fetch)
		.onDisappear(perform: imageFetcher.cancel)
	}

	public func setPlaceholder(image: UIImage) -> some View {
		self.placeholder = image
		return body
	}
}
