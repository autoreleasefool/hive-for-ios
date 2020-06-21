//
//  SessionToken.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-30.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

struct SessionToken: Decodable {
	let sessionId: UUID
	let userId: User.ID
	let token: String
}
