//
//  Emoji.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-08.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

enum Emoji: String, CaseIterable {
	case noJo = "NoJo"
	case hive = "Hive"
	case scottCry = "ScottCry"
	case mobileExperience = "MobileExperience"
	case dead = "Dead"

	var image: UIImage? {
		UIImage(named: rawValue)
	}
}
