//
//  Date+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

extension Date {
	var isToday: Bool {
		switch Calendar.current.compare(self, to: Date(), toGranularity: .day) {
		case .orderedSame: return true
		case .orderedAscending, .orderedDescending: return false
		}
	}

	var isThisYear: Bool {
		switch Calendar.current.compare(self, to: Date(), toGranularity: .year) {
		case .orderedSame: return true
		case .orderedAscending, .orderedDescending: return false
		}
	}
}
