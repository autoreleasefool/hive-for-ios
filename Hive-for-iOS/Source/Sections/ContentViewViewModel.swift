//
//  ContentViewViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-15.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

enum ContentViewViewAction: BaseViewAction {
	case onAppear
}

enum ContentViewAction: BaseAction {
	case loadAccount
	case loadOfflineAccount
	case loggedOut
}

class ContentViewViewModel: ViewModel<ContentViewViewAction>, ObservableObject {
	@Published var isShowingSettings = false
	@Published var isPlayingOnline = false
	@Published var isPlayingOffline = false {
		didSet {
			actions.send(.loadOfflineAccount)
		}
	}

	override init() {
		super.init()
		subscribeToAccountUpdates()
	}

	private let actions = PassthroughSubject<ContentViewAction, Never>()
	var actionsPublisher: AnyPublisher<ContentViewAction, Never> {
		actions.eraseToAnyPublisher()
	}

	override func postViewAction(_ viewAction: ContentViewViewAction) {
		switch viewAction {
		case .onAppear:
			actions.send(.loadAccount)
		}
	}

	private func subscribeToAccountUpdates() {
		NotificationCenter.default
			.publisher(for: NSNotification.Name.Account.Unauthorized)
			.map { _ in }
			.receive(on: RunLoop.main)
			.sink { [weak self] in self?.actions.send(.loggedOut) }
			.store(in: self)
	}

	var isPlaying: Binding<Bool> {
		Binding { [weak self] in
			(self?.isPlayingOnline ?? false) || (self?.isPlayingOffline ?? false)
		} set: { [weak self] newValue in
			guard !newValue else { return }
			self?.isPlayingOffline = false
			self?.isPlayingOnline = false
		}
	}
}
