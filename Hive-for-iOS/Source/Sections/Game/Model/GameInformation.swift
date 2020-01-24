//
//  GameInformation.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import HiveEngine

enum GameInformation {
	case unit(HiveEngine.Unit)

	var text: String {
		switch self {
		case .unit(let unit): return unit.description
		}
	}
}
