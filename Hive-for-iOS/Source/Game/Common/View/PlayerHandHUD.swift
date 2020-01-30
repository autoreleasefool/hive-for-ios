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
			RoundedRectangle(cornerRadius: Metrics.Spacing.small.rawValue)
				.fill(Color(ColorAsset.background))
			HStack {
				ZStack {
					Text(unitClass.notation)
						.foregroundColor(Color(ColorAsset.text))
						.subtitle()
					Hex()
						.stroke(Color(ColorAsset.text), lineWidth: CGFloat(2))
						.frame(width: 48, height: 48)
				}
				VStack {
					Text(unitClass.description)
						.foregroundColor(Color(ColorAsset.text))
						.title()
					Text(count > 0 ? "\(count) remaining" : "All in play")
						.foregroundColor(Color(ColorAsset.textSecondary))
						.body()
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
