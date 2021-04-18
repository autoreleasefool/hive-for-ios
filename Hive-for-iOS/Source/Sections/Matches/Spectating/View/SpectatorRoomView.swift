//
//  SpectatorRoomView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-08-20.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import HiveFoundation
import SwiftUI

struct SpectatorRoomView: View {
	@Environment(\.presentationMode) private var presentationMode
	@Environment(\.toaster) private var toaster
	@Environment(\.container) private var container

	@StateObject private var viewModel: SpectatorRoomViewModel

	init(id: Match.ID?, match: Loadable<Match> = .notLoaded) {
		_viewModel = StateObject(wrappedValue: SpectatorRoomViewModel(matchId: id, match: match))
	}

	var body: some View {
		content
			.navigationBarTitle(Text("Spectating..."), displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(leading: cancelButton)
			.onReceive(viewModel.actionsPublisher) { handleAction($0) }
			.alert(isPresented: $viewModel.isCancelling) {
				Alert(
					title: Text("Stop spectating?"),
					message: Text("Are you sure you want to stop spectating this match?"),
					primaryButton: .destructive(Text("Stop")) {
						viewModel.postViewAction(.confirmExit)
					},
					secondaryButton: .cancel(Text("Stay")) {
						viewModel.postViewAction(.dismissExit)
					})
			}
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.match {
		case .notLoaded: notLoadedView
		case .loading, .loaded, .failed: loadingView
		}
	}

	// MARK: Content

	private var notLoadedView: some View {
		Text("")
			.background(Color(.backgroundRegular).edgesIgnoringSafeArea(.all))
			.onAppear { viewModel.postViewAction(.onAppear) }
	}

	private var loadingView: some View {
		LoadingView()
	}

	// MARK: Buttons

	private var cancelButton: some View {
		Button {
			viewModel.postViewAction(.cancel)
		} label: {
			Text("Cancel")
		}
	}
}

// MARK: - Actions

extension SpectatorRoomView {
	private func handleAction(_ action: SpectatorRoomAction) {
		switch action {
		case .loadMatch(let matchId):
			loadMatch(id: matchId)
		case .openClientConnection(let url):
			openClientConnection(to: url)
		case .startGame(let state):
			guard let match = viewModel.match.value else {
				handleAction(.failedToSpectateMatch)
				return
			}
			container.appState[\.gameSetup] = Game.Setup(match: match, state: state, mode: .spectate)
		case .exit:
			presentationMode.wrappedValue.dismiss()
		case .failedToSpectateMatch, .matchNotOpenForSpectating:
			toaster.loaf.send(LoafState("Failed to start spectating", style: .error()))
			presentationMode.wrappedValue.dismiss()
		}
	}

	private func loadMatch(id: Match.ID) {
		container.interactors.matchInteractor
			.loadMatchDetails(id: id, match: $viewModel.match)
	}
}

// MARK: GameClient

extension SpectatorRoomView {
	private func openClientConnection(to url: URL?) {
		let publisher: AnyPublisher<GameClientEvent, GameClientError>
		if let url = url {
			container.interactors.clientInteractor
				.prepare(.online, clientConfiguration: .online(url, container.account))
			publisher = container.interactors.clientInteractor
				.openConnection(.online)
		} else {
			publisher = container.interactors.clientInteractor
				.reconnect(.online)
		}

		viewModel.postViewAction(.subscribedToClient(publisher))
	}
}

// MARK: - Preview

#if DEBUG
struct SpectatorRoomViewPreview: PreviewProvider {
	static var previews: some View {
		SpectatorRoomView(id: Match.matches[1].id, match: .loaded(Match.matches[1]))
	}
}
#endif
