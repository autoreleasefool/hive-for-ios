//
//  ViewModel.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2020-01-17.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine

public protocol BaseViewAction { }

public protocol BaseAction { }

open class ViewModel<ViewAction> where ViewAction: BaseViewAction {

	private var cancellables: [AnyCancellable] = []

	public init() {}

	open func postViewAction(_ viewAction: ViewAction) {
		fatalError("Classes extending ViewModel must override postViewAction(_:)")
	}

	public func cancelAll() {
		cancellables.removeAll()
	}

	fileprivate func store(_ cancellable: AnyCancellable) {
		cancellable.store(in: &cancellables)
	}
}

open class ExtendedViewModel<ViewAction, CancelIdentifiable>: ViewModel<ViewAction> where
	CancelIdentifiable: Identifiable,
	ViewAction: BaseViewAction {

	private var idenfitiedCancellables: [CancelIdentifiable.ID: AnyCancellable] = [:]

	override public init() {
		super.init()
	}

	override public func cancelAll() {
		super.cancelAll()
		idenfitiedCancellables.removeAll()
	}

	public func cancel(withId id: CancelIdentifiable) {
		guard let cancellable = idenfitiedCancellables[id.id] else { return }
		cancellable.cancel()
		idenfitiedCancellables[id.id] = nil
	}

	fileprivate func store(_ cancellable: AnyCancellable, _ id: CancelIdentifiable?) {
		if let id = id {
			idenfitiedCancellables[id.id] = cancellable
		} else {
			store(cancellable)
		}
	}
}

extension AnyCancellable {
	public func store<V>(in model: ViewModel<V>) {
		model.store(self)
	}

	public func store<V, I>(in model: ExtendedViewModel<V, I>, withId id: I? = nil) where I: Identifiable {
		model.store(self, id)
	}
}
