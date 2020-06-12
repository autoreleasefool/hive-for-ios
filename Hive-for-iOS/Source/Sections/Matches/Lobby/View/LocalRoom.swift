//
//  LocalRoom.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-06-11.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct LocalRoom: View {
	@Environment(\.presentationMode) private var presentationMode
	@Environment(\.toaster) private var toaster
	@Environment(\.container) private var container

	@ObservedObject private var viewModel = LocalRoomViewModel()

	var body: some View {
		content
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

	private var content: AnyView {
		AnyView(EmptyView())
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
			self.viewModel.postViewAction(.startGame)
		}, label: {
			Text("Start")
		})
	}

	// MARK: Match Detail

	private func matchDetail(_ match: Match) -> some View {
		EmptyView()
//		RoomDetails(
//			host: match.host,
//			hostIsReady: viewModel.isPlayerReady(id: match.host?.id),
//			opponent: match.opponent,
//			opponentIsReady: viewModel.isPlayerReady(id: match.opponent?.id),
//			optionsDisabled: !viewModel.userIsHost,
//			isGameOptionEnabled: viewModel.gameOptionEnabled,
//			isOptionEnabled: viewModel.optionEnabled
//		)
	}
}

// MARK: - Actions

extension LocalRoom {
	private func handleAction(_ action: LocalRoomAction) {

	}
}
