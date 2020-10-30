//
//  Store.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-20.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
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

extension Binding where Value: Equatable {
	func dispatched<State>(to state: Store<State>, _ keypath: WritableKeyPath<State, Value>) -> Self {
		.init(
			get: { () -> Value in
				self.wrappedValue
			},
			set: { newValue in
				self.wrappedValue = newValue
				state[keypath] = newValue
			}
		)
	}
}
