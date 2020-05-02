//
//  Store.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-20.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine

typealias Store<Value> = CurrentValueSubject<Value, Never>

extension Store {
	subscript<T>(keyPath: WritableKeyPath<Output, T>) -> T where T: Equatable {
		get { value[keyPath: keyPath] }
		set {
			var value = self.value
			if value[keyPath: keyPath] != newValue {
				value[keyPath: keyPath] = newValue
				self.value = value
			}
		}
	}

	func updates<Value>(for keyPath: KeyPath<Output, Value>) -> AnyPublisher<Value, Failure> where Value: Equatable {
		map(keyPath).removeDuplicates().eraseToAnyPublisher()
	}
}
