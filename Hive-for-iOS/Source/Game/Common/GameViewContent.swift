//
//  GameViewContent.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-02-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import SpriteKit

enum GameViewContent {
	#if AR_AVAILABLE
	case arExperience(Experience.HiveGame)
	#endif
	case skScene(SKScene)
}
