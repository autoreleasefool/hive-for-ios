//
//  EdgeInsets+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

extension EdgeInsets {
	init(equalTo equal: CGFloat) {
		self.init(top: equal, leading: equal, bottom: equal, trailing: equal)
	}

	init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
		self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
	}
}
