//
//  UnitCard.swift
//  Hive for iOS
//
//  Created by Joseph Roque on 2019-12-01.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct UnitCard: View {
	let state: GameState
	let player: Player
	let unitClass: HiveEngine.Unit.Class

	var body: some View {
		ZStack {
			Rectangle().fill(Color(UIColor(named: "BackgroundCard")!))


		}
	}
}
