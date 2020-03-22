//
//  CoreGraphics+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import CoreGraphics

func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	CGPoint(x: lhs.x + rhs.y, y: lhs.y + rhs.y)
}

func +=(lhs: inout CGPoint, rhs: CGPoint) {
	lhs.x += rhs.x
	lhs.y += rhs.y
}
