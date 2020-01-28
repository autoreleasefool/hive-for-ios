//
//  PlayerHandHUD.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-28.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct PlayerHandHUD: View {
	let hand: PlayerHand

	private func card(unitClass: HiveEngine.Unit.Class, count: Int) -> some View {
		ZStack {
			RoundedRectangle(cornerRadius: Metrics.Spacing.smaller)
				.fill(Assets.Color.background.color)
			HStack {
				ZStack {
					Text(unitClass.notation)
						.foregroundColor(Assets.Color.text.color)
						.font(.system(size: Metrics.Text.subtitle))
					Hex()
						.stroke(Assets.Color.text.color, lineWidth: CGFloat(2))
						.frame(width: 48, height: 48)
				}
				VStack {
					Text(unitClass.description)
						.foregroundColor(Assets.Color.text.color)
						.font(.system(size: Metrics.Text.title))
					Text(count > 0 ? "\(count) remaining" : "All in play")
						.foregroundColor(Assets.Color.textSecondary.color)
						.font(.system(size: Metrics.Text.body))
				}
			}
		}
		.frame(width: 300)
	}

	var body: some View {
		VStack {
			Text("\(hand.player.description) hand")
			ScrollView(.horizontal, showsIndicators: false) {
				HStack {
					ForEach(hand.unitsInHand.keys.sorted()) { unitClass in
						self.card(unitClass: unitClass, count: self.hand.unitsInHand[unitClass]!)
					}
				}
			}
		}
	}
}

#if DEBUG
struct PlayerHandHUDPreview: PreviewProvider {
	static var previews: some View {
		EmptyView()
	}
}
#endif
