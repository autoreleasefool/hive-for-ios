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
			ForEach(AgentConfiguration.allCases) { computer in
				NavigationLink(destination: LocalRoom(opponent: computer)) {
					HStack(spacing: .m) {
						Text(computer.name)
							.body()
							.foregroundColor(Color(.text))
					}
				}
			}
		}
		.background(Color(.background).edgesIgnoringSafeArea(.all))
		.listRowInsets(EdgeInsets(equalTo: .m))
		.navigationBarTitle("Pick an opponent")
	}
}
