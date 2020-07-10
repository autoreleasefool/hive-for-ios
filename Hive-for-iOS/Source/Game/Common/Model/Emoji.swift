//
//  Emoji.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-08.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

enum Emoji: String, CaseIterable {
	case scottCry = "ScottCry"

	var image: UIImage? {
		UIImage(named: rawValue)
	}
}
