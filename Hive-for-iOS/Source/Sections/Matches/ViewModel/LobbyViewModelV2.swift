//
//  LobbyViewModelV2.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-03.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine

enum LobbyViewActionV2: BaseViewAction {
}

class LobbyViewModelV2: ViewModel<LobbyViewActionV2>, ObservableObject {
	@Published var matches: Loadable<[Match]> = .notLoaded

	var isRefreshing: Binding<Bool> {
		Binding(
			get: { [weak self] in
				if case .loading = self?.matches {
					return true
				}
				return false
			},
			set: { _ in }
		)
	}
}
