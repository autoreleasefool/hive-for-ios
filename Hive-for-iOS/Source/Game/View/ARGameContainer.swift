//
//  ARGameContainer.swift
//  Hive for iOS
//
//  Created by Joseph Roque on 2019-11-30.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import SwiftUI

struct ARGameContainer: View {
	@ObservedObject var viewModel: GameViewModel

	init(viewModel: GameViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		return ARGameView().edgesIgnoringSafeArea(.all)
	}
}
