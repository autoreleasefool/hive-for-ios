//
//  Profile.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct Profile: View {
	@ObservedObject private var viewModel: ProfileViewModel

	init(viewModel: ProfileViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		List {
			HexImage(url: viewModel.user?.avatarUrl, placeholder: ImageAsset.borderlessGlyph, stroke: .primary)
				.placeholderTint(.primary)
				.squareImage(.m)
		}
	}
}
