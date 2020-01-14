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

class ImageLoader {

	static let shared: ImageLoader = ImageLoader()

	private let cache = NSCache<NSURL, UIImage>()
	private let queryQueueLock = NSLock()
	private var queryCompletionQueue: [String: [(Result<(URL, UIImage), ImageLoaderError>) -> Void]] = [:]

	@discardableResult
	func fetch(string: String) -> Future<(URL, UIImage), ImageLoaderError> {
		return fetch(url: URL(string: string))
	}

	@discardableResult
	func fetch(url: URL?) -> Future<(URL, UIImage), ImageLoaderError> {
		return Future { [unowned self] promise in
			guard let url = url else {
				promise(.failure(.invalidURL))
				return
			}

			if let cachedImage = self.cached(url: url) {
				promise(.success((url, cachedImage)))
				return
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
		return cache.object(forKey: url as NSURL)
	}

	private func performFetch(for url: URL, promise: @escaping (Result<(URL, UIImage), ImageLoaderError>) -> Void) {
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
				finished(.failure(.networkingError(url, error!)))
				return
			}

			guard let response = response as? HTTPURLResponse else {
				finished(.failure(.invalidResponse(url)))
				return
			}

			guard (200..<400).contains(response.statusCode) else {
				finished(.failure(.invalidHTTPResponse(url, response.statusCode)))
				return
			}

			guard let data = data else {
				finished(.failure(.invalidData(url)))
				return
			}

			self.image(for: data, fromURL: url, completion: finished)
		}.resume()
	}

	private func image(for data: Data, fromURL url: URL, completion: @escaping (Result<(URL, UIImage), ImageLoaderError>) -> Void) {
		guard let image = UIImage(data: data) else {
			completion(.failure(.invalidData(url)))
			return
		}

		cache.setObject(image, forKey: url as NSURL)
		completion(.success((url, image)))
	}
}
