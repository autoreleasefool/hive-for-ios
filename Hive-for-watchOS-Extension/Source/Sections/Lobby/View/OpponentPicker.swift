//
//  OpponentPicker.swift
//  Hive-for-watchOS-Extension
//
//  Created by Joseph Roque on 2021-04-18.
//  Copyright © 2021 Joseph Roque. All rights reserved.
//

import Foundation
import HiveFoundation
import SwiftUI

struct OpponentPicker: View {
	@Environment(\.container) private var container

	var body: some View {
		List {
			Section(header: Text("Computer").foregroundColor(Color(.textSecondary))) {
				ForEach(AgentConfiguration.allCases.filter { $0.isEnabled(in: container.features) }) { computer in
					NavigationLink(destination: RoomView(opponent: .agent(computer))) {
						Text(computer.name)
							.font(.body)
							.foregroundColor(.textRegular)
							.padding(.vertical)
					}
				}
			}
		}
	}
}
