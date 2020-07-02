//
//  ComputerPlayerPicker.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-06-28.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct ComputerPlayerPicker: View {
	let isActive: Binding<Bool>

	var body: some View {
		List {
			ForEach(ComputerEnemy.Player.allCases) { player in
				NavigationLink(destination: LocalRoom(opponent: player, isActive: self.isActive)) {
					HStack(spacing: .m) {
						Text(player.name)
							.body()
							.foregroundColor(Color(.text))
					}
				}
			}
		}
		.listRowInsets(EdgeInsets(equalTo: .m))
		.navigationBarTitle("Pick an opponent")
	}
}
