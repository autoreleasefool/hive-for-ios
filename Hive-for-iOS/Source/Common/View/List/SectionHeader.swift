//
//  SectionHeader.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-11-26.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct SectionHeader: View {
	private let title: String

	init(_ title: String) {
		self.title = title
	}

	var body: some View {
		Text(title)
			.foregroundColor(Color(.textSecondary))
	}
}
