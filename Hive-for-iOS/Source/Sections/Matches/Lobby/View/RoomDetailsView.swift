//
//  RoomDetailsView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-06-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct RoomDetailsView: View {
	let host: UserPreview.UserSummary?
	let isHostReady: Bool
	let opponent: UserPreview.UserSummary?
	let isOpponentReady: Bool
	let optionsDisabled: Bool

	let gameOptionsEnabled: Set<GameState.Option>
	let matchOptionsEnabled: Set<Match.Option>
	let gameOptionBinding: (GameState.Option) -> Binding<Bool>
	let matchOptionBinding: (Match.Option) -> Binding<Bool>

	var body: some View {
		List {
			Section(header: Text("Players")) {
				playerSection
			}
			Section(header: Text("Expansions")) {
				expansionsSection
			}
			Section(header: Text("Match options")) {
				matchOptionsSection
			}
			Section(header: Text("Other options")) {
				otherOptionsSection
			}
		}
		.listStyle(InsetGroupedListStyle())
	}

	private var playerSection: some View {
		VStack(alignment: .leading) {
			summary(forPlayer: host, isReady: isHostReady)
			Divider()
			summary(forPlayer: opponent, isReady: isOpponentReady)
		}
	}

	private func summary(forPlayer player: UserPreview.UserSummary?, isReady: Bool) -> some View {
		HStack(spacing: 0) {
			UserPreview(
				player,
				highlight: isReady,
				iconSize: .l
			)
			Spacer(minLength: Metrics.Spacing.s.rawValue)

			if isReady {
				Text("READY")
					.font(.caption)
					.foregroundColor(Color(.highlightSuccess))
			} else {
				Text("WAITING")
					.font(.caption)
					.foregroundColor(Color(.highlightDestructive))
			}
		}
	}

	private var expansionsSection: some View {
		ForEach(GameState.Option.expansions, id: \.rawValue) { option in
			Toggle(name(forOption: option), isOn: gameOptionBinding(option))
				.disabled(optionsDisabled)
		}
	}

	private var matchOptionsSection: some View {
		ForEach(Match.Option.enabledOptions, id: \.rawValue) { option in
			Toggle(name(forOption: option), isOn: matchOptionBinding(option))
				.disabled(optionsDisabled)
		}
	}

	private var otherOptionsSection: some View {
		ForEach(GameState.Option.nonExpansions, id: \.rawValue) { option in
			Toggle(name(forOption: option), isOn: gameOptionBinding(option))
				.disabled(optionsDisabled)
		}
	}
}

// MARK: - Strings

extension RoomDetailsView {
	private func name(forOption option: Match.Option) -> String {
		switch option {
		case .asyncPlay: return "Asynchronous play"
		case .hostIsWhite: return "\(host?.displayName ?? "Host") is white"
		}
	}

	private func name(forOption option: GameState.Option) -> String {
		return option.displayName
	}
}

// MARK: - Preview

#if DEBUG
struct RoomDetailsViewPreview: PreviewProvider {
	private static let gameOptions: Set<GameState.Option> = [.mosquito, .allowSpecialAbilityAfterYoink]
	private static let matchOptions: Set<Match.Option> = [.hostIsWhite]

	static var previews: some View {
		RoomDetailsView(
			host: User.users[0].summary,
			isHostReady: true,
			opponent: User.users[0].summary,
			isOpponentReady: false,
			optionsDisabled: false,
			gameOptionsEnabled: Self.gameOptions,
			matchOptionsEnabled: Self.matchOptions,
			gameOptionBinding: { .constant(Self.gameOptions.contains($0)) },
			matchOptionBinding: { .constant(Self.matchOptions.contains($0)) }
		)
	}
}
#endif
