//
//  ImageLoader.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import UIKit
import Combine

enum ImageLoaderError: Error {
	case invalidURL
	case invalidData(URL)
	case networkingError(URL, Error)
	case invalidResponse(URL)
	case invalidHTTPResponse(URL, Int)
}

typealias ImageLoaderFuture = Future<(URL, UIImage), ImageLoaderError>
typealias ImageLoaderPromise = ImageLoaderFuture.Promise

class ImageLoader {

	static let shared: ImageLoader = ImageLoader()

	private let cache = NSCache<NSURL, UIImage>()
	private let queryQueueLock = NSLock()
	private var queryCompletionQueue: [String: [ImageLoaderPromise]] = [:]

	@discardableResult
	func fetch(string: String) -> ImageLoaderFuture {
		fetch(url: URL(string: string))
	}

	@discardableResult
	func fetch(url: URL?) -> ImageLoaderFuture {
		Future { [unowned self] promise in
			guard let url = url else {
				return promise(.failure(.invalidURL))
			}

			if let cachedImage = self.cached(url: url) {
				return promise(.success((url, cachedImage)))
			}

			DispatchQueue.global(qos: .background).async { [unowned self] in
				self.performFetch(for: url, promise: promise)
			}
		}
	}

	func cached(string: String) -> UIImage? {
		guard let url = URL(string: string) else { return nil }
		return cached(url: url)
	}

	func cached(url: URL) -> UIImage? {
		cache.object(forKey: url as NSURL)
	}

	private func performFetch(for url: URL, promise: @escaping ImageLoaderPromise) {
		defer { queryQueueLock.unlock() }
		queryQueueLock.lock()

		func finished(_ result: Result<(URL, UIImage), ImageLoaderError>) {
			defer { queryQueueLock.unlock() }
			queryQueueLock.lock()

			if let queryQueue = queryCompletionQueue[url.absoluteString] {
				queryQueue.forEach { $0(result) }
			}
			queryCompletionQueue[url.absoluteString] = nil
		}

		if var queryQueue = queryCompletionQueue[url.absoluteString] {
			queryQueue.append(promise)
			queryCompletionQueue[url.absoluteString] = queryQueue
			return
		}

		queryCompletionQueue[url.absoluteString] = [promise]
		URLSession.shared.dataTask(with: url) { [unowned self] data, response, error in
			guard error == nil else {
				return finished(.failure(.networkingError(url, error!)))
			}

			guard let response = response as? HTTPURLResponse else {
				return finished(.failure(.invalidResponse(url)))
			}

			guard (200..<400).contains(response.statusCode) else {
				return finished(.failure(.invalidHTTPResponse(url, response.statusCode)))
			}

			guard let data = data else {
				return finished(.failure(.invalidData(url)))
			}

			self.image(for: data, fromURL: url, completion: finished)
		}.resume()
	}

	private func image(for data: Data, fromURL url: URL, completion: @escaping ImageLoaderPromise) {
		guard let image = UIImage(data: data) else {
			return completion(.failure(.invalidData(url)))
		}

		cache.setObject(image, forKey: url as NSURL)
		completion(.success((url, image)))
	}
}
