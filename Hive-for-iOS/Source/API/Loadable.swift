//
//  Loadable.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

final class CancelBag {
	var subscriptions: Set<AnyCancellable> = []

	func cancel() {
		subscriptions.forEach { $0.cancel() }
		subscriptions.removeAll()
	}
}

extension AnyCancellable {
	func store(in cancelBag: CancelBag) {
		cancelBag.subscriptions.insert(self)
	}
}

typealias LoadableSubject<T> = Binding<Loadable<T>>

enum Loadable<T> {
	case notLoaded
	case loading(cached: T?, cancelBag: CancelBag)
	case loaded(T)
	case failed(Error)

	var value: T? {
		switch self {
		case .notLoaded, .failed: return nil
		case .loading(let v, _): return v
		case .loaded(let v): return v
		}
	}

	var error: Error? {
		switch self {
		case .notLoaded, .loading, .loaded: return nil
		case .failed(let error): return error
		}
	}
}

extension Loadable: Equatable where T: Equatable {
	static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
		switch (lhs, rhs) {
		case (.notLoaded, .notLoaded): return true
		case (.loading(let lhs, _), .loading(let rhs, _)): return lhs == rhs
		case (.loaded(let lhs), .loaded(let rhs)): return lhs == rhs
		case (.failed(let lhs), .failed(let rhs)):
			return lhs.localizedDescription == rhs.localizedDescription
		default: return false
		}
	}
}
