//
//  BasicRoom.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-06-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct RoomDetails: View {
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
		ScrollView {
			VStack(spacing: .m) {
				playerSection
				Divider().background(Color(.dividerRegular))
				expansionsSection
				Divider().background(Color(.dividerRegular))
				matchOptionsSection
				Divider().background(Color(.dividerRegular))
				otherOptionsSection
				Spacer()
			}
		}
		.padding(.all, length: .m)
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
	}

	private var expansionsSection: some View {
		VStack(alignment: .leading) {
			Text("Expansions")
				.bold()
				.body()
				.foregroundColor(Color(.textRegular))
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
			HStack(spacing: .l) {
				Spacer()
				ForEach(GameState.Option.expansions, id: \.rawValue) { option in
					self.expansionOption(for: option, enabled: self.gameOptionBinding(option).wrappedValue)
				}
				Spacer()
			}
		}
	}

	private func expansionOption(for option: GameState.Option, enabled: Bool) -> some View {
		Button(action: {
			self.gameOptionBinding(option).wrappedValue.toggle()
		}, label: {
			ZStack {
				Text(name(forOption: option))
					.subtitle()
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
		})
		.disabled(optionsDisabled)
	}

	private var matchOptionsSection: some View {
		VStack(alignment: .leading) {
			optionSectionHeader(title: "Match options")
			ForEach(Match.Option.enabledOptions, id: \.rawValue) { option in
				Toggle(self.name(forOption: option), isOn: self.matchOptionBinding(option))
					.disabled(self.optionsDisabled)
					.foregroundColor(Color(.textRegular))
			}
		}
	}

	private var otherOptionsSection: some View {
		VStack(alignment: .leading) {
			optionSectionHeader(title: "Other options")
			ForEach(GameState.Option.nonExpansions, id: \.rawValue) { option in
				Toggle(self.name(forOption: option), isOn: self.gameOptionBinding(option))
					.disabled(self.optionsDisabled)
					.foregroundColor(Color(.textRegular))
			}
		}
	}

	private func optionSectionHeader(title: String) -> some View {
		Text(title)
			.bold()
			.body()
			.foregroundColor(Color(.textRegular))
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
	}
}

// MARK: - Strings

extension RoomDetails {
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
