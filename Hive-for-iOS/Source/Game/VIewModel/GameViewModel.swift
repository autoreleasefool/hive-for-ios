//
//  GameViewModel.swift
//  Hive for iOS
//
//  Created by Joseph Roque on 2019-11-30.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine
import HiveEngine

class GameViewModel: ObservableObject, Identifiable {
	@Published var state = GameState()
}
