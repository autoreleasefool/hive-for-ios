//
//  TabHostingView.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-10-12.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine
import SwiftUI

enum TabRefreshReason {
	case accountChanged(Loadable<Account>)
}

protocol TabItemViewModel: AnyObject {
	func tabShouldRefresh(dueToReason reason: TabRefreshReason)
}

protocol TabItemView: View {
	func onTabItemAppeared(completion: @escaping (TabItemViewModel) -> Void) -> Self
}

class TabHostingViewModel: ObservableObject {
	weak var tabItemViewModel: TabItemViewModel?
}

struct TabHostingView<Content: TabItemView>: View {

	@Environment(\.container) private var container

	@State private var account: Loadable<Account> = .notLoaded
	@StateObject private var viewModel = TabHostingViewModel()

	private var content: () -> Content

	init(@ViewBuilder content: @escaping () -> Content) {
		self.content = content
	}

	var body: some View {
		content()
			.onTabItemAppeared { viewModel in
				self.viewModel.tabItemViewModel = viewModel
			}
			.onReceive(accountUpdate) {
				guard account != $0 else { return }
				account = $0
				viewModel.tabItemViewModel?.tabShouldRefresh(dueToReason: .accountChanged($0))
			}
	}
}

// MARK: - Updates

extension TabHostingView {
	private var accountUpdate: AnyPublisher<Loadable<Account>, Never> {
		container.appState.updates(for: \.account)
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
	}
}
