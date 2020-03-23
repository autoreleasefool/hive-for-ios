//
//  CoreGraphics+Extensions.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-22.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import CoreGraphics

// MARK: CGPoint

func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
	CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

func += (lhs: inout CGPoint, rhs: CGPoint) {
	lhs.x += rhs.x
	lhs.y += rhs.y
}

func -= (lhs: inout CGPoint, rhs: CGPoint) {
	lhs.x -= rhs.x
	lhs.y -= rhs.y
}

func *= (lhs: inout CGPoint, rhs: CGFloat) {
	lhs.x *= rhs
	lhs.y *= rhs
}

// MARK: CGSize

func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
	CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}
