//
//  UserDefaults+Extensions.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2021-04-19.
//  Copyright © 2021 Joseph Roque. All rights reserved.
//

import Foundation

extension UserDefaults {
	static let group: UserDefaults = {
		UserDefaults(suiteName: "group.ca.josephroque.hiveapp") ?? UserDefaults.shared
	}()
}
