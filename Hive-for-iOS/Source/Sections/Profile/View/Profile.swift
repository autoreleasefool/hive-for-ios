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

	init(user: Loadable<User> = .notLoaded) {
		self._user = .init(initialValue: user)
	}

	var body: some View {
		List {
			HexImage(url: user.value?.avatarUrl, placeholder: ImageAsset.borderlessGlyph, stroke: .primary)
				.placeholderTint(.primary)
				.squareImage(.m)
		}
	}
}

#if DEBUG
struct ProfilePreview: PreviewProvider {
	static var previews: some View {
		Profile()
	}
}
#endif
