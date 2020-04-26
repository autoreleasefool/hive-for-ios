//
//  LoafState.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import UIKit
import Loaf

struct LoafState: Hashable, Equatable {
	private static var lastId = 0
	private static func nextId() -> Int {
		lastId += 1
		return lastId
	}

	private let id: Int
	let message: String
	let state: Loaf.State
	let location: Loaf.Location
	let presentingDirection: Loaf.Direction
	let dismissingDirection: Loaf.Direction
	let duration: Loaf.Duration?
	let onDismiss: Loaf.LoafCompletionHandler

	init(
		_ message: String,
		state: Loaf.State = .info,
		location: Loaf.Location = .bottom,
		presentingDirection: Loaf.Direction = .vertical,
		dismissingDirection: Loaf.Direction = .vertical,
		duration: Loaf.Duration? = nil,
		onDismiss: Loaf.LoafCompletionHandler = nil
	) {
		self.id = Self.nextId()
		self.message = message
		self.state = state
		self.location = location
		self.presentingDirection = presentingDirection
		self.dismissingDirection = dismissingDirection
		self.duration = duration
		self.onDismiss = onDismiss
	}

	func show(withSender sender: UIViewController) {
		Loaf(
			message,
			state: state,
			location: location,
			presentingDirection: presentingDirection,
			dismissingDirection: dismissingDirection,
			sender: sender
		).show(duration ?? .average, completionHandler: onDismiss)
	}

	func build() -> Loaf {
		Loaf(
			message,
			state: state,
			location: location,
			presentingDirection: presentingDirection,
			dismissingDirection: dismissingDirection,
			duration: duration ?? .average
		)
	}

	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
