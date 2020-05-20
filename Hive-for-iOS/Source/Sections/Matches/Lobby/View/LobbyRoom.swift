//
//  LobbyRoom.swift
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

struct LobbyRoom: View {
	@Environment(\.presentationMode) private var presentationMode
	@Environment(\.toaster) private var toaster: Toaster
	@Environment(\.container) private var container: AppContainer

	@ObservedObject private var viewModel: LobbyRoomViewModel

	init(id: Match.ID?, creatingRoom: Bool, match: Loadable<Match> = .notLoaded) {
		self.viewModel = LobbyRoomViewModel(matchId: id, creatingNewMatch: creatingRoom, match: match)
	}

	var body: some View {
		GeometryReader { geometry in
			self.content(geometry)
		}
		.background(Color(.background).edgesIgnoringSafeArea(.all))
		.navigationBarTitle(Text(viewModel.title), displayMode: .inline)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: exitButton, trailing: startButton)
		.onReceive(viewModel.actionsPublisher) { self.handleAction($0) }
		.popoverSheet(isPresented: $viewModel.exiting) {
			PopoverSheetConfig(
				title: "Leave match?",
				message: "Are you sure you want to leave this match?",
				buttons: [
					PopoverSheetConfig.ButtonConfig(title: "Leave", type: .destructive) {
						self.viewModel.postViewAction(.exitMatch)
					},
					PopoverSheetConfig.ButtonConfig(title: "Stay", type: .cancel) {
						self.viewModel.postViewAction(.dismissExit)
					},
				]
			)
		}
	}

	private func content(_ geometry: GeometryProxy) -> AnyView {
		switch viewModel.match {
		case .notLoaded: return AnyView(notLoadedView)
		case .loading(let match, _): return AnyView(loadedView(match, geometry))
		case .loaded(let match): return AnyView(loadedView(match, geometry))
		case .failed(let error): return AnyView(failedView(error))
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.onAppear { self.viewModel.postViewAction(.onAppear(self.container.account?.userId)) }
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
				if self.viewModel.reconnecting {
					reconnectingView(geometry)
				} else {
					matchDetail(match!)
				}
			}
		}
		.pullToRefresh(isShowing: viewModel.isRefreshing) {
			guard !self.viewModel.reconnecting else { return }
			self.viewModel.postViewAction(.refresh)
		}
	}

	private func failedView(_ error: Error) -> some View {
		EmptyState(
			header: "An error occurred",
			message: "We can't fetch the match right now.\n\(viewModel.errorMessage(from: error))"
		) {
			self.viewModel.postViewAction(.retryInitialAction)
		}
	}

	private func reconnectingView(_ geometry: GeometryProxy) -> some View {
		VStack(spacing: .m) {
			Text("The connection to the server was lost.\nPlease wait while we try to reconnect you.")
				.multilineTextAlignment(.center)
				.body()
				.foregroundColor(Color(.text))
			ActivityIndicator(isAnimating: true, style: .whiteLarge)
			Text(viewModel.reconnectingMessage)
				.multilineTextAlignment(.center)
				.body()
				.foregroundColor(Color(.text))
			Spacer()
		}
		.padding(.all, length: .m)
		.padding(.top, length: .xl)
		.frame(width: geometry.size.width)
	}

	// MARK: Buttons

	private var exitButton: some View {
		Button(action: {
			self.viewModel.postViewAction(.requestExit)
		}, label: {
			Text("Leave")
		})
	}

	private var startButton: some View {
		Button(action: {
			self.viewModel.postViewAction(.toggleReadiness)
		}, label: {
			Text(viewModel.startButtonText)
		})
	}

	// MARK: Match Detail

	private func matchDetail(_ match: Match) -> some View {
		VStack(spacing: .m) {
			self.playerSection(match)
			Divider().background(Color(.divider))
			self.expansionSection
			Divider().background(Color(.divider))
			self.otherOptionsSection
		}
		.padding(.all, length: .m)
	}

	private func playerSection(_ match: Match) -> some View {
		HStack(spacing: .xs) {
			UserPreview(
				match.host?.summary,
				highlight: self.viewModel.isPlayerReady(id: match.host?.id),
				iconSize: .l
			)
			Spacer()
			UserPreview(
				match.opponent?.summary,
				highlight: self.viewModel.isPlayerReady(id: match.opponent?.id),
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
					self.expansionOption(for: option, enabled: self.viewModel.gameOptions.contains(option))
				}
				Spacer()
			}
		}
	}

	private func expansionOption(for option: GameState.Option, enabled: Bool) -> some View {
		Button(action: {
			self.viewModel.gameOptionEnabled(option: option).wrappedValue.toggle()
		}, label: {
			ZStack {
				Text(viewModel.name(forOption: option))
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
		.disabled(!viewModel.userIsHost)
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
				Toggle(self.viewModel.name(forOption: option), isOn: self.viewModel.optionEnabled(option: option))
					.disabled(!self.viewModel.userIsHost)
					.foregroundColor(Color(.text))
			}
		}
	}

	private var otherOptionsSection: some View {
		VStack(alignment: .leading) {
			self.optionSectionHeader(title: "Other options")
			ForEach(GameState.Option.nonExpansions, id: \.rawValue) { option in
				Toggle(self.viewModel.name(forOption: option), isOn: self.viewModel.gameOptionEnabled(option: option))
					.disabled(!self.viewModel.userIsHost)
					.foregroundColor(Color(.text))
			}
		}
	}
}

// MARK: - Actions

extension LobbyRoom {
	private func handleAction(_ action: LobbyRoomAction) {
		switch action {
		case .createNewMatch:
			createNewMatch()
		case .joinMatch:
			joinMatch()
		case .loadMatchDetails:
			loadMatchDetails()
		case .startGame(let state, let player):
			startGame(state: state, player: player)

		case .openClientConnection(let url):
			openClientConnection(to: url)
		case .closeConnection(let code):
			close(code: code)
		case .sendMessage(let message):
			send(message)

		case .failedToJoinMatch:
			failedToJoin()
		case .failedToReconnect:
			failedToReconnect()
		case .exitSilently:
			exitSilently()
		case .exitMatch:
			exitMatch()

		case .showLoaf(let loaf):
			toaster.loaf.send(loaf)
		}
	}

	private func startGame(state: GameState, player: Player) {
		container.appState[\.gameSetup] = GameContentCoordinator.GameSetup(
			state: state,
			player: player
		)
	}

	private func joinMatch() {
		guard let id = viewModel.initialMatchId else { return }
		container.interactors.matchInteractor
			.joinMatch(id: id, match: $viewModel.match)
	}

	private func createNewMatch() {
		container.interactors.matchInteractor
			.createNewMatch(match: $viewModel.match)
	}

	private func loadMatchDetails() {
		guard let id = viewModel.match.value?.id else { return }
		container.interactors.matchInteractor
			.loadMatchDetails(id: id, match: $viewModel.match)
	}

	private func failedToJoin() {
		toaster.loaf.send(LoafState("Failed to join match", state: .error))
		presentationMode.wrappedValue.dismiss()
	}

	private func failedToReconnect() {
		toaster.loaf.send(LoafState("Failed to reconnect", state: .error))
		presentationMode.wrappedValue.dismiss()
	}

	private func exitSilently() {
		presentationMode.wrappedValue.dismiss()
	}

	private func exitMatch() {
		send(.forfeit)
		close(code: nil)
		presentationMode.wrappedValue.dismiss()
	}
}

// MARK: - HiveGameClient

extension LobbyRoom {
	private func openClientConnection(to url: URL?) {
		let publisher: AnyPublisher<GameClientEvent, GameClientError>
		if let url = url {
			publisher = container.interactors.clientInteractor
				.openConnection(to: url)
		} else {
			publisher = container.interactors.clientInteractor
				.reconnect()
		}

		viewModel.postViewAction(.subscribedToClient(publisher))
	}

	private func send(_ message: GameClientMessage) {
		container.interactors.clientInteractor
			.send(message)
	}

	private func close(code: CloseCode?) {
		container.interactors.clientInteractor
			.closeConnection(code: code)
	}

	private func closeConnection(code: CloseCode?) {
		close(code: code)
		presentationMode.wrappedValue.dismiss()
	}
}

#if DEBUG
struct LobbyRoomPreview: PreviewProvider {
	static var previews: some View {
		return LobbyRoom(id: Match.matches[0].id, creatingRoom: false, match: .loaded(Match.matches[0]))
	}
}
#endif
