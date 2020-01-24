//
//  UIView+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import UIKit

extension UIView {
	func constrainToFillView(_ other: UIView) {
		constrainToFillViewVertically(other)
		constrainToFillViewHorizontally(other)
	}

	func constrainToFillViewVertically(_ other: UIView) {
		self.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate(constraintsToFillViewVertically(other))
	}

	func constraintsToFillViewVertically(_ other: UIView) -> [NSLayoutConstraint] {
		return [
			self.topAnchor.constraint(equalTo: other.topAnchor),
			self.bottomAnchor.constraint(equalTo: other.bottomAnchor),
		]
	}

	func constrainToFillViewHorizontally(_ other: UIView) {
		self.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate(constraintsToFillViewHorizontally(other))
	}

	func constraintsToFillViewHorizontally(_ other: UIView) -> [NSLayoutConstraint] {
		return [
			self.leftAnchor.constraint(equalTo: other.leftAnchor),
			self.rightAnchor.constraint(equalTo: other.rightAnchor),
		]
	}
}
