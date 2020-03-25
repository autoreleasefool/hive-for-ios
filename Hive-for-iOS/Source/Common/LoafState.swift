//
//  LoafState.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import UIKit
import Loaf

struct LoafState {
	let message: String
	let state: Loaf.State
	let location: Loaf.Location
	let presentingDirection: Loaf.Direction
	let dismissingDirection: Loaf.Direction
	let duration: Loaf.Duration?

	init(
		_ message: String,
		state: Loaf.State = .info,
		location: Loaf.Location = .bottom,
		presentingDirection: Loaf.Direction = .vertical,
		dismissingDirection: Loaf.Direction = .vertical,
		duration: Loaf.Duration? = nil
	) {
		self.message = message
		self.state = state
		self.location = location
		self.presentingDirection = presentingDirection
		self.dismissingDirection = dismissingDirection
		self.duration = duration
	}

	func build(withSender sender: UIViewController? = nil) -> Loaf {
		if let sender = sender {
			return Loaf(
				message,
				state: state,
				location: location,
				presentingDirection: presentingDirection,
				dismissingDirection: dismissingDirection,
				sender: sender
			)
		} else {
			return Loaf(
				message,
				state: state,
				location: location,
				presentingDirection: presentingDirection,
				dismissingDirection: dismissingDirection,
				duration: duration ?? .average
			)
		}
	}
}
