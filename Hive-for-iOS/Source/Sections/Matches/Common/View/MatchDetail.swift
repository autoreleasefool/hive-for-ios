//
//  MatchDetail.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import HiveEngine

struct MatchDetail: View {
	private let match: Match
	private let editable: Bool
	private let matchOptions: Set<Match.Option>
	private let gameOptions: Set<GameState.Option>
	private let readyPlayers: Set<Match.User.ID>

	private var onMatchOptionToggled: (Match.Option, Bool) -> Void
	private var onGameOptionToggled: (GameState.Option, Bool) -> Void

	init(
		match: Match,
		editable: Bool = false,
		matchOptions: Set<Match.Option>? = nil,
		gameOptions: Set<GameState.Option>? = nil,
		readyPlayers: Set<Match.User.ID> = Set()
	) {
		self.match = match
		self.editable = editable
		self.matchOptions = matchOptions ?? match.optionSet
		self.gameOptions = gameOptions ?? match.gameOptionSet
		self.readyPlayers = readyPlayers

		self.onMatchOptionToggled = { _, _ in }
		self.onGameOptionToggled = { _, _ in }
	}

	var body: some View {
		GeometryReader { geometry in
			VStack(spacing: .m) {
				self.playerSection
				Divider().background(Color(.divider))
				self.expansionSection
				Divider().background(Color(.divider))
				self.otherOptionsSection
			}
			.padding(.all, length: .m)
			.frame(width: geometry.size.width)
		}
	}

	// MARK: Match Details

	private var playerSection: some View {
		HStack(spacing: .xs) {
			MatchUserSummary(
				self.match.host,
				highlight: self.isPlayerReady(id: self.match.host?.id),
				iconSize: .l
			)
			Spacer()
			MatchUserSummary(
				self.match.opponent,
				highlight: self.isPlayerReady(id: self.match.opponent?.id),
				alignment: .trailing,
				iconSize: .l
			)
		}
	}

	var expansionSection: some View {
		VStack(alignment: .leading) {
			Text("Expansions")
				.bold()
				.body()
				.foregroundColor(Color(.text))
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
			HStack(spacing: .l) {
				Spacer()
				ForEach(GameState.Option.expansions, id: \.rawValue) { option in
					self.expansionOption(for: option, enabled: self.gameOptions.contains(option))
				}
				Spacer()
			}
		}
	}

	private func expansionOption(for option: GameState.Option, enabled: Bool) -> some View {
		Button(action: {
			self.gameOptionEnabled(option: option).wrappedValue.toggle()
		}, label: {
			ZStack {
				Text(name(forOption: option))
					.subtitle()
					.foregroundColor(
						enabled
							? Color(.primary)
							: Color(.textSecondary)
					)
				Hex()
					.stroke(
						enabled
							? Color(.primary)
							: Color(.textSecondary),
						lineWidth: CGFloat(5)
					)
					.squareImage(.l)
			}
		})
		.disabled(!editable)
	}

	private func optionSectionHeader(title: String) -> some View {
		Text(title)
			.bold()
			.body()
			.foregroundColor(Color(.text))
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
	}

	private var matchOptionsSection: some View {
		VStack(alignment: .leading) {
			self.optionSectionHeader(title: "Match options")
			ForEach(Match.Option.enabledOptions, id: \.rawValue) { option in
				Toggle(self.name(forOption: option), isOn: self.optionEnabled(option: option))
					.disabled(!self.editable)
					.foregroundColor(Color(.text))
			}
		}
	}

	private var otherOptionsSection: some View {
		VStack(alignment: .leading) {
			self.optionSectionHeader(title: "Other options")
			ForEach(GameState.Option.nonExpansions, id: \.rawValue) { option in
				Toggle(self.name(forOption: option), isOn: self.gameOptionEnabled(option: option))
					.disabled(!self.editable)
					.foregroundColor(Color(.text))
			}
		}
	}
}

// MARK: - Actions

extension MatchDetail {
	func isPlayerReady(id: UUID?) -> Bool {
		guard let id = id else { return false }
		return readyPlayers.contains(id)
	}

	func optionEnabled(option: Match.Option) -> Binding<Bool> {
		Binding(
			get: { self.matchOptions.contains(option) },
			set: {
				guard self.editable else { return }
				self.onMatchOptionToggled(option, $0)
			}
		)
	}

	func gameOptionEnabled(option: GameState.Option) -> Binding<Bool> {
		Binding(
			get: { self.gameOptions.contains(option) },
			set: {
				guard self.editable else { return }
				self.onGameOptionToggled(option, $0)
			}
		)
	}
}

// MARK: - Strings

extension MatchDetail {
	func name(forOption option: Match.Option) -> String {
		switch option {
		case .asyncPlay: return "Asynchronous play"
		case .hostIsWhite: return "\(match.host?.displayName ?? "Host") is white"
		}
	}

	func name(forOption option: GameState.Option) -> String {
		return option.preview ?? option.displayName
	}
}

private extension GameState.Option {
	var preview: String? {
		switch self {
		case .mosquito: return "M"
		case .ladyBug: return "L"
		case .pillBug: return "P"
		default: return nil
		}
	}
}

// MARK: Modifiers

extension MatchDetail {
	func onMatchOptionToggled(_ callback: @escaping (Match.Option, Bool) -> Void) -> Self {
		var copy = self
		copy.onMatchOptionToggled = callback
		return copy
	}

	func onGameOptionToggled(_ callback: @escaping (GameState.Option, Bool) -> Void) -> Self {
		var copy = self
		copy.onGameOptionToggled = callback
		return copy
	}
}

#if DEBUG
struct MatchDetailPreview: PreviewProvider {
	static var previews: some View {
		return MatchDetail(match: Match.matches[0])
	}
}
#endif
