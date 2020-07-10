//
//  Array+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-08.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

extension Array {
	func chunked(into size: Int) -> [[Element]] {
		stride(from: 0, to: count, by: size).map { Array(self[$0..<Swift.min($0 + size, count)]) }
	}
}
