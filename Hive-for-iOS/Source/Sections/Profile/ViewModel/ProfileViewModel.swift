//
//  ProfileViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import Combine

enum ProfileViewAction: BaseViewAction {
	case onAppear
	case refreshProfile
}

class ProfileViewModel: ViewModel<ProfileViewAction>, ObservableObject {
	@Published private(set) var user: User?

	private(set) var userId: User.ID

	private(set) var breadBox = PassthroughSubject<LoafState, Never>()
	private(set) var refreshComplete = PassthroughSubject<Void, Never>()

	private var api: HiveAPI!

	init(userId: User.ID) {
		self.userId = userId
	}

	override func postViewAction(_ action: ProfileViewAction) {
		switch action {
		case .onAppear, .refreshProfile:
			fetchProfileDetails()
		}
	}

	private func fetchProfileDetails() {
//		api.user(id: userId, withAccount: account)
//			.receive(on: DispatchQueue.main)
//			.sink(
//				receiveCompletion: { [weak self] result in
//					self?.refreshComplete.send()
//					if case let .failure(error) = result {
//						self?.breadBox.send(error.loaf)
//					}
//				},
//				receiveValue: { [weak self] user in
//					self?.user = user
//				}
//			)
//			.store(in: self)
	}

	func setAPI(to api: HiveAPI) {
		self.api = api
	}
}
