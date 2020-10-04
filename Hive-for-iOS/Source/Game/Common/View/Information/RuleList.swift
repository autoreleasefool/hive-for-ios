//
//  RuleList.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-29.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct RuleList: View {
	@EnvironmentObject var viewModel: GameViewModel

	var body: some View {
		VStack(spacing: Metrics.Spacing.m) {
			ForEach(GameRule.allCases, id: \.rawValue) { rule in
				Button {
					viewModel.postViewAction(.presentInformation(.rule(rule)))
				} label: {
					Text(rule.title)
						.font(.body)
						.foregroundColor(Color(.highlightPrimary))
						.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
				}
			}
		}
	}
}

// MARK: - Preview

#if DEBUG
struct RuleListPreview: PreviewProvider {
	static var previews: some View {
		RuleList()
	}
}
#endif
