//
//  GameAction.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-25.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

enum GameAction {
	case confirmMovement(PopoverSheetConfig)

	var config: PopoverSheetConfig {
		switch self {
		case .confirmMovement(let config): return config
		}
	}
}
