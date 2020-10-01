//
//  UIView+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import UIKit

extension UIView {
	func addSubviewForAutoLayout(_ view: UIView) {
		view.translatesAutoresizingMaskIntoConstraints = false
		addSubview(view)
	}

	func constrainToFillView(_ other: UIView) {
		constrainToFillViewVertically(other)
		constrainToFillViewHorizontally(other)
	}

	func constrainToFillViewVertically(_ other: UIView) {
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate(constraintsToFillViewVertically(other))
	}

	func constraintsToFillViewVertically(_ other: UIView) -> [NSLayoutConstraint] {
		[
			topAnchor.constraint(equalTo: other.topAnchor),
			bottomAnchor.constraint(equalTo: other.bottomAnchor),
		]
	}

	func constrainToFillViewHorizontally(_ other: UIView) {
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate(constraintsToFillViewHorizontally(other))
	}

	func constraintsToFillViewHorizontally(_ other: UIView) -> [NSLayoutConstraint] {
		[
			leftAnchor.constraint(equalTo: other.leftAnchor),
			rightAnchor.constraint(equalTo: other.rightAnchor),
		]
	}
}
