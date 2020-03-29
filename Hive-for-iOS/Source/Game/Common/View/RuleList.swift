//
//  RuleList.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-29.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct RuleList: View {
	@EnvironmentObject var viewModel: HiveGameViewModel

	var body: some View {
		VStack(spacing: Metrics.Spacing.s.rawValue) {
			ForEach(HiveRule.allCases, id: \.rawValue) { rule in
				Button(action: {
					self.viewModel.postViewAction(.presentInformation(.rule(rule)))
				}, label: {
					Text(rule.title)
						.body()
						.foregroundColor(Color(.primary))
						.padding(.vertical, length: .xs)
						.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
				})
			}
		}
	}
}
