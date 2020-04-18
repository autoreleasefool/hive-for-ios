//
//  NetworkSession.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-18.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

protocol NetworkSession {
	func loadData(from request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: NetworkSession {
	func loadData(from request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
		dataTask(with: request, completionHandler: completionHandler).resume()
	}
}
