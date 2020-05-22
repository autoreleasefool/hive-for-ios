//
//  Publisher+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine

extension Publisher {
	func sinkToLoadable(_ completion: @escaping (Loadable<Output>) -> Void) -> AnyCancellable {
		return sink(
			receiveCompletion: {
				if let error = $0.error {
					completion(.failed(error))
				}
			}, receiveValue: {
				completion(.loaded($0))
			}
		)
	}
}

extension Subscribers.Completion {
	var error: Failure? {
		switch self {
		case let .failure(error): return error
		default: return nil
		}
	}
}
