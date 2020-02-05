//
//  Logger.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-02-05.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

var debugEnabled: Bool = true

func debugLog(_ message: String) {
	guard debugEnabled else { return }
	print("HIVE_DEBUG: \(message)")
}
