//
//  Set+Extensions.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2020-04-26.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

extension Set {
	public mutating func set(_ value: Element, to included: Bool) {
		if included {
			insert(value)
		} else {
			remove(value)
		}
	}

	public mutating func toggle(_ element: Element) {
		if contains(element) {
			remove(element)
		} else {
			insert(element)
		}
	}
}
