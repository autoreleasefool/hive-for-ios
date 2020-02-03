//
//  MovementConfirmation.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-02-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct MovementConfirmation: View {
	@EnvironmentObject var viewModel: HiveGameViewModel
	let movement: Movement

	var body: some View {
		EmptyView()
	}
}

#if DEBUG
struct MovementConfirmationPreview: PreviewProvider {
	static var previews: some View {
		MovementConfirmation(movement: .move(unit: Piece(class: .queen, owner: .white, index: 1), to: .origin))
	}
}
#endif
