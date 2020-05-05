//
//  Profile.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct Profile: View {

	@State private var user: Loadable<User> = .notLoaded

	var body: some View {
		List {
			HexImage(url: user.value?.avatarUrl, placeholder: ImageAsset.borderlessGlyph, stroke: .primary)
				.placeholderTint(.primary)
				.squareImage(.m)
		}
	}
}
