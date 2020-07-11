//
//  AnimatedEmoji.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-10.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct AnimateableEmoji {
	enum Source {
		case picked
		case fromOpponent
	}

	let emoji: Emoji
	let source: Source
}

struct AnimatedEmoji: View {
	let emoji: AnimateableEmoji

	var body: some View {
		EmptyView()
	}
}
