//
//  AgentPicker.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-06-28.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct AgentPicker: View {
	@Environment(\.container) private var container
	let isActive: Binding<Bool>

	var body: some View {
		List {
			ForEach(AgentConfiguration.allCases.filter { $0.isEnabled(in: container.features) }) { computer in
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
