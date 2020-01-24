//
//  ARGameViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine

enum ARGameTask: Identifiable {
	var id: String {
		return ""
	}
}

enum ARGameViewAction: BaseViewAction {

}

class ARGameViewModel: ViewModel<ARGameViewAction, ARGameTask>, ObservableObject {
	override func postViewAction(_ viewAction: ARGameViewAction) {

	}
}
