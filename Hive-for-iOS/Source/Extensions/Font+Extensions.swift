//
//  Font+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

extension Font {
	static func system(size: Metrics.Text) -> Font {
		system(size: size.rawValue)
	}
}
