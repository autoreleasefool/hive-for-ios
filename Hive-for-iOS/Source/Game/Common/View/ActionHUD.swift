//
//  ActionHUD.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-25.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct ActionHUD: View {
	@EnvironmentObject var viewModel: HiveGameViewModel
	let action: GameAction

	var body: some View {
		action.config.bottomSheet()
	}
}

#if DEBUG
struct ActionHUDPreview: PreviewProvider {
	static var previews: some View {
		EmptyView()
	}
}
#endif
