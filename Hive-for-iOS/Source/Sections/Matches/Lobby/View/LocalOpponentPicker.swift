//
//  LocalOpponentPicker.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-06-28.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct LocalOpponentPicker: View {
	@Environment(\.container) private var container
	let isActive: Binding<Bool>

	var body: some View {
		List {
			Section(header: SectionHeader("Local")) {
				NavigationLink(destination: LocalRoomView(opponent: .human)) {
					Text("Play against a friend on this device")
						.font(.body)
						.foregroundColor(Color(.textRegular))
						.padding(.vertical)
				}
				.accessibility(identifier: "playAgainstFriend")
			}
			.listRowBackground(Color(.backgroundLight))

			Section(header: SectionHeader("Computer")) {
				ForEach(AgentConfiguration.allCases.filter { $0.isEnabled(in: container.features) }) { computer in
					NavigationLink(destination: LocalRoomView(opponent: .agent(computer))) {
						Text(computer.name)
							.font(.body)
							.foregroundColor(Color(.textRegular))
							.padding(.vertical)
					}
				}
			}
			.listRowBackground(Color(.backgroundLight))
		}
		.listStyle(InsetGroupedListStyle())
		.navigationBarTitle("Local match")
	}
}

// MARK: - Preview

#if DEBUG
struct LocalOpponentPickerPreview: PreviewProvider {
	static var previews: some View {
		LocalOpponentPicker(isActive: .constant(true))
	}
}
#endif
