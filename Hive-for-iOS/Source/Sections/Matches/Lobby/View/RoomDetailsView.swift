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
	let hostIsReady: Bool
	let opponent: UserPreview.UserSummary?
	let opponentIsReady: Bool
	let optionsDisabled: Bool

	let gameOptionsEnabled: Set<GameState.Option>
	let matchOptionsEnabled: Set<Match.Option>
	let gameOptionBinding: (GameState.Option) -> Binding<Bool>
	let matchOptionBinding: (Match.Option) -> Binding<Bool>

	var body: some View {
		Form {
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
		HStack(spacing: .s) {
			UserPreview(
				host,
				highlight: hostIsReady,
				iconSize: .l
			)
			Spacer()
			UserPreview(
				opponent,
				highlight: opponentIsReady,
				iconSize: .l
			)
		}
		.padding()
	}

	private var expansionsSection: some View {
		VStack(alignment: .leading) {
			HStack(spacing: .l) {
				Spacer()
				ForEach(GameState.Option.expansions, id: \.rawValue) { option in
					expansionOption(for: option, enabled: gameOptionBinding(option).wrappedValue)
				}
				Spacer()
			}
		}
		.padding()
	}

	private func expansionOption(for option: GameState.Option, enabled: Bool) -> some View {
		Button {
			gameOptionBinding(option).wrappedValue.toggle()
		} label: {
			ZStack {
				Text(name(forOption: option))
					.font(.headline)
					.foregroundColor(
						enabled
							? Color(.highlightPrimary)
							: Color(.textSecondary)
					)
				Hex()
					.stroke(
						enabled
							? Color(.highlightPrimary)
							: Color(.textSecondary),
						lineWidth: CGFloat(5)
					)
					.squareImage(.l)
			}
		}
		.disabled(optionsDisabled)
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
		return option.preview ?? option.displayName
	}
}

private extension GameState.Option {
	var preview: String? {
		switch self {
		case .mosquito: return "M"
		case .ladyBug: return "L"
		case .pillBug: return "P"
		case .noFirstMoveQueen, .allowSpecialAbilityAfterYoink: return nil
		}
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
			hostIsReady: true,
			opponent: User.users[0].summary,
			opponentIsReady: false,
			optionsDisabled: true,
			gameOptionsEnabled: Self.gameOptions,
			matchOptionsEnabled: Self.matchOptions,
			gameOptionBinding: { .constant(Self.gameOptions.contains($0)) },
			matchOptionBinding: { .constant(Self.matchOptions.contains($0)) }
		)
	}
}
#endif
