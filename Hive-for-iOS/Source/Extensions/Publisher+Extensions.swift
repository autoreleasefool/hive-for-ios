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
			receiveCompletion: { subscriptionCompletion in
				if let error = subscriptionCompletion.error {
					completion(.failed(error))
				}
			}, receiveValue: { value in
				completion(.loaded(value))
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
