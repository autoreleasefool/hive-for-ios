//
//  MatchDetail.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI
import HiveEngine
import Starscream
import SwiftUIRefresh

private final class MatchDetailState: ObservableObject {
	@Published var match: Loadable<Match> = .notLoaded {
		didSet {
			matchOptions = match.value?.optionSet ?? Set()
			gameOptions = match.value?.gameOptionSet ?? Set()
		}
	}

	@Published var matchOptions: Set<Match.Option> = Set()
	@Published var gameOptions: Set<GameState.Option> = Set()
	@Published var readyPlayers: Set<UUID> = Set()
	var cancelBag = CancelBag()
}

struct MatchDetail: View {
	@Environment(\.presentationMode) private var presentationMode
	@Environment(\.toaster) private var toaster: Toaster
	@Environment(\.container) private var container: AppContainer

	@State private var matchId: Match.ID?

	@ObservedObject private var matchState = MatchDetailState()

	@State private var gameState: GameState?
	@State private var exiting = false

	@State private var clientConnected = false
	@State private var reconnectAttempts = 0
	@State private var reconnecting = false

	init(id: Match.ID?, match: Loadable<Match> = .notLoaded) {
		self.matchId = id
		self.matchState.match = match
	}

	var body: some View {
		GeometryReader { geometry in
			NavigationLink(
				destination: HiveGame(state: self.gameState, player: self.player) {
					self.presentationMode.wrappedValue.dismiss()
				},
				isActive: self.inGame,
				label: { EmptyView() }
			)

			self.content(geometry)
		}
		.background(Color(.background).edgesIgnoringSafeArea(.all))
		.navigationBarTitle(Text(title), displayMode: .inline)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: exitButton, trailing: startButton)
		.onReceive(matchState.$match) {
			if let match = $0.value {
				self.openClientConnection(to: match)
			}
		}
		.popoverSheet(isPresented: $exiting) {
			PopoverSheetConfig(
				title: "Leave match?",
				message: "Are you sure you want to leave this match?",
				buttons: [
					PopoverSheetConfig.ButtonConfig(title: "Leave", type: .destructive) {
						self.exiting = false
						self.exitMatch()
					},
					PopoverSheetConfig.ButtonConfig(title: "Stay", type: .cancel) {
						self.exiting = false
					},
				]
			)
		}
	}

	private func content(_ geometry: GeometryProxy) -> AnyView {
		switch matchState.match {
		case .notLoaded: return AnyView(notLoadedView)
		case .loading(let match, _): return AnyView(loadedView(match, geometry))
		case .loaded(let match): return AnyView(loadedView(match, geometry))
		case .failed: return AnyView(failedView)
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.onAppear {
				if self.matchId == nil {
					self.createNewMatch()
				} else {
					self.joinMatch()
				}
			}
	}

	private func loadedView(_ match: Match?, _ geometry: GeometryProxy) -> some View {
		ScrollView {
			if match == nil {
				HStack {
					Spacer()
					ActivityIndicator(isAnimating: true, style: .whiteLarge)
					Spacer()
				}
				.padding(.top, length: .m)
				.frame(width: geometry.size.width)
			} else {
				if self.reconnecting {
					reconnectingView(geometry)
				} else {
					VStack(spacing: .m) {
						self.playerSection(match: match!)
						Divider().background(Color(.divider))
						self.expansionSection
						Divider().background(Color(.divider))
						self.otherOptionsSection
					}
					.padding(.all, length: .m)
					.frame(width: geometry.size.width)
				}
			}
		}
		.pullToRefresh(isShowing: isRefreshing) {
			guard !self.reconnecting else { return }
			self.loadMatchDetails()
		}
	}

	// TODO: failedView
	private var failedView: some View {
		EmptyView()
	}

	private func reconnectingView(_ geometry: GeometryProxy) -> some View {
		VStack(spacing: .m) {
			Text("The connection to the server was lost.\nPlease wait while we try to reconnect you.")
				.multilineTextAlignment(.center)
				.body()
				.foregroundColor(Color(.text))
			ActivityIndicator(isAnimating: true, style: .whiteLarge)
			Text(reconnectingMessage)
				.multilineTextAlignment(.center)
				.body()
				.foregroundColor(Color(.text))
			Spacer()
		}
		.padding(.all, length: .m)
		.padding(.top, length: .xl)
		.frame(width: geometry.size.width)
	}

	// MARK: Match Details

	private func playerSection(match: Match) -> some View {
		HStack(spacing: .xs) {
			MatchUserSummary(
				match.host,
				highlight: self.isPlayerReady(id: match.host?.id),
				iconSize: .l
			)
			Spacer()
			MatchUserSummary(
				match.opponent,
				highlight: self.isPlayerReady(id: match.opponent?.id),
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
					self.expansionOption(for: option, enabled: self.matchState.gameOptions.contains(option))
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
		.disabled(!userIsHost)
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
					.disabled(!self.userIsHost)
					.foregroundColor(Color(.text))
			}
		}
	}

	private var otherOptionsSection: some View {
		VStack(alignment: .leading) {
			self.optionSectionHeader(title: "Other options")
			ForEach(GameState.Option.nonExpansions, id: \.rawValue) { option in
				Toggle(self.name(forOption: option), isOn: self.gameOptionEnabled(option: option))
					.disabled(!self.userIsHost)
					.foregroundColor(Color(.text))
			}
		}
	}

	// MARK: Buttons

	private var exitButton: some View {
		Button(action: {
			self.exiting = true
		}, label: {
			Text("Leave")
		})
	}

	private var startButton: some View {
		Button(action: {
			self.toggleReadiness()
		}, label: {
			Text(startButtonText)
		})
	}
}

// MARK: - Actions

extension MatchDetail {
	var inGame: Binding<Bool> {
		Binding(
			get: { self.gameState != nil },
			set: { newValue in
				if !newValue {
					self.gameState = nil
				}
			}
		)
	}

	var player: Player {
		if matchState.matchOptions.contains(.hostIsWhite) {
			return userIsHost ? .white : .black
		} else {
			return userIsHost ? .black : .white
		}
	}

	var userIsHost: Bool {
		container.account?.userId == matchState.match.value?.host?.id
	}

	var isRefreshing: Binding<Bool> {
		Binding(
			get: {
				if case .loading = self.matchState.match {
					return true
				}
				return false
			},
			set: { _ in }
		)
	}

	func isPlayerReady(id: UUID?) -> Bool {
		guard let id = id else { return false }
		return matchState.readyPlayers.contains(id)
	}

	func optionEnabled(option: Match.Option) -> Binding<Bool> {
		Binding(
			get: { self.matchState.matchOptions.contains(option) },
			set: {
				guard self.userIsHost else { return }
				self.matchState.matchOptions.set(option, to: $0)
				self.send(.setOption(.matchOption(option), $0))
			}
		)
	}

	func gameOptionEnabled(option: GameState.Option) -> Binding<Bool> {
		Binding(
			get: { self.matchState.gameOptions.contains(option) },
			set: {
				guard self.userIsHost else { return }
				self.matchState.gameOptions.set(option, to: $0)
				self.send(.setOption(.gameOption(option), $0))
			}
		)
	}

	private func toggleReadiness() {
		guard let id = userIsHost ? matchState.match.value?.host?.id : matchState.match.value?.opponent?.id else {
			return
		}

		if isPlayerReady(id: id) {
			matchState.readyPlayers.remove(id)
			send(.readyToPlay)
		} else {
			matchState.readyPlayers.insert(id)
			send(.readyToPlay)
		}
	}

	private func playerJoined(id: UUID) {
		if userIsHost {
			toaster.loaf.send(LoafState("An opponent has joined!", state: .success))
		}
		loadMatchDetails()
	}

	private func playerLeft(id: UUID) {
		matchState.readyPlayers.remove(id)
		if userIsHost && id == matchState.match.value?.opponent?.id {
			toaster.loaf.send(LoafState("Your opponent has left!", state: .warning))
			loadMatchDetails()
		} else if !userIsHost && id == matchState.match.value?.host?.id {
			toaster.loaf.send(LoafState("The host has left!", state: .warning))
			close(code: nil)
			presentationMode.wrappedValue.dismiss()
		}
	}

	private func updateGameState(to state: GameState) {
		gameState = state
	}

	private func setOption(_ option: GameServerMessage.Option, to value: Bool) {
		switch option {
		case .gameOption(let option): matchState.gameOptions.set(option, to: value)
		case .matchOption(let option): matchState.matchOptions.set(option, to: value)
		}
	}

	private func joinMatch() {
		guard let id = matchId else { return }
		container.interactors.matchInteractor
			.joinMatch(id: id, withAccount: container.account, match: $matchState.match)
	}

	private func createNewMatch() {
		container.interactors.matchInteractor
			.createNewMatch(withAccount: container.account, match: $matchState.match)
	}

	private func loadMatchDetails() {
		guard let id = matchId else { return }
		container.interactors.matchInteractor
			.loadMatchDetails(id: id, withAccount: container.account, match: $matchState.match)
	}

	private func exitMatch() {
		send(.forfeit)
		close(code: nil)
		presentationMode.wrappedValue.dismiss()
	}
}

// MARK: - Updates

extension MatchDetail {
	var accountUpdate: AnyPublisher<Loadable<Account>, Never> {
		container.appState.updates(for: \.account)
	}
}

// MARK: - HiveGameClient

extension MatchDetail {
	private func send(_ message: GameClientMessage) {
		container.interactors.clientInteractor
			.send(message)
	}

	private func close(code: CloseCode?) {
		container.interactors.clientInteractor
			.closeConnection(code: code)
	}

	private func openClientConnection(to match: Match) {
		if let url = match.webSocketURL {
			openClientConnection(to: url)
		} else {
			toaster.loaf.send(LoafState("Failed to join match", state: .error))
			presentationMode.wrappedValue.dismiss()
		}
	}

	private func reopenClientConnection() {
		openClientConnection(to: nil)
	}

	private func openClientConnection(to url: URL?) {
		LoadingHUD.shared.show()

		let publisher: AnyPublisher<GameClientEvent, GameClientError>
		if let url = url {
			publisher = container.interactors.clientInteractor
				.openConnection(to: url)
		} else {
			publisher = container.interactors.clientInteractor
				.reconnect()
		}

		publisher
			.sink(
				receiveCompletion: {
					if case let .failure(error) = $0 {
						self.handleGameClientError(error)
					}
				}, receiveValue: {
					self.handleGameClientEvent($0)
				}
			)
			.store(in: matchState.cancelBag)
	}

	private func handleGameClientError(_ error: GameClientError) {
		guard reconnectAttempts < HiveGameClient.maxReconnectAttempts else {
			LoadingHUD.shared.hide()
			toaster.loaf.send(LoafState("Failed to reconnect", state: .error))
			presentationMode.wrappedValue.dismiss()
			return
		}

		reconnecting = true
		reconnectAttempts += 1
		reopenClientConnection()
	}

	private func handleGameClientEvent(_ event: GameClientEvent) {
		switch event {
		case .connected:
			clientConnected = true
			reconnecting = false
			reconnectAttempts = 0
			LoadingHUD.shared.hide()
		case .closed:
			presentationMode.wrappedValue.dismiss()
		case .message(let message):
			handleGameClientMessage(message)
		}
	}

	private func handleGameClientMessage(_ message: GameServerMessage) {
		switch message {
		case .playerJoined(let id):
			playerJoined(id: id)
		case .playerLeft(let id):
			playerLeft(id: id)
		case .gameState(let state):
			updateGameState(to: state)
		case .playerReady(let id, let ready):
			matchState.readyPlayers.set(id, to: ready)
		case .setOption(let option, let value):
			setOption(option, to: value)
		case .message(let id, let string):
			#warning("TODO: display message")
			print("Received message '\(string)' from \(id)")
		case .error(let error):
			toaster.loaf.send(error.loaf)
		case .forfeit, .gameOver:
			print("Received invalid message in Match Details: \(message)")
		}
	}
}

// MARK: - Strings

extension MatchDetail {
	var title: String {
		if let host = matchState.match.value?.host?.displayName {
			return "\(host)'s match"
		} else {
			return "Match Details"
		}
	}

	var startButtonText: String {
		guard let hostId = matchState.match.value?.host?.id,
			let opponentId = matchState.match.value?.opponent?.id else {
			return ""
		}

		let user = userIsHost ? hostId : opponentId
		let opponent = userIsHost ? opponentId : hostId

		if matchState.readyPlayers.contains(user) {
			return "Cancel"
		} else {
			return matchState.readyPlayers.contains(opponent) ? "Start" : "Ready"
		}
	}

	func name(forOption option: Match.Option) -> String {
		switch option {
		case .asyncPlay: return "Asynchronous play"
		case .hostIsWhite: return "\(matchState.match.value?.host?.displayName ?? "Host") is white"
		}
	}

	func name(forOption option: GameState.Option) -> String {
		return option.preview ?? option.displayName
	}

	var reconnectingMessage: String {
		"Reconnecting (\(reconnectAttempts)/\(HiveGameClient.maxReconnectAttempts))..."
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

#if DEBUG
struct MatchDetailPreview: PreviewProvider {
	static var previews: some View {
		let match = Match.matches[0]
		let loadable: Loadable<Match> = .loaded(match)
		return MatchDetail(id: match.id, match: loadable)
	}
}
#endif
