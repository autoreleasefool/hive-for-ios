//
//  String+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-02-04.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

extension String {
	func substring(from index: Int) -> String {
		return String(self.suffix(from: self.index(self.startIndex, offsetBy: index)))
	}
}
