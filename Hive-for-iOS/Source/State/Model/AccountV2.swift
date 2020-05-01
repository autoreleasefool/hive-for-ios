//
//  AccountV2.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-01.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

struct AccountV2: Equatable {
	struct Detail: Equatable {
		var userId: User.ID
		var token: String
	}

	var detail: Loadable<Detail> = .notLoaded
}
