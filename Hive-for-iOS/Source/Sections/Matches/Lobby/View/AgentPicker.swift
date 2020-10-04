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
			Section(header: Text("Opponent")) {
				ForEach(AgentConfiguration.allCases.filter { $0.isEnabled(in: container.features) }) { computer in
					NavigationLink(destination: LocalRoomView(opponent: computer)) {
						Text(computer.name)
							.font(.body)
							.padding(.vertical)
					}
				}
			}
		}
		.listStyle(InsetGroupedListStyle())
		.navigationBarTitle("Local match")
	}
}

// MARK: - Preview

#if DEBUG
struct AgentPickerPreview: PreviewProvider {
	static var previews: some View {
		AgentPicker(isActive: .constant(true))
	}
}
#endif
