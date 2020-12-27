//
//  User+Update.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-12-26.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

extension User {
	enum Update {}
}

extension User.Update {
	struct Request: Codable {
		let displayName: String?
		let avatarUrl: String?
	}
}
