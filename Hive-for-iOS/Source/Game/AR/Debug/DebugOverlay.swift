//
//  DebugOverlay.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-18.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import UIKit
import HiveEngine

enum TouchPosition {
	case simd3(SIMD3<Float>)
	case cgPoint(CGPoint)

	var x: CGFloat {
		switch self {
		case .simd3(let position): return CGFloat(position.x)
		case .cgPoint(let position): return position.x
		}
	}

	var y: CGFloat {
		switch self {
		case .simd3(let position): return CGFloat(position.y)
		case .cgPoint(let position): return position.y
		}
	}

	var z: CGFloat {
		switch self {
		case .simd3(let position): return CGFloat(position.z)
		case .cgPoint: return 0
		}
	}

	var point: CGPoint {
		CGPoint(x: x, y: y)
	}

	var simd3: SIMD3<Float> {
		SIMD3<Float>(x: Float(x), y: Float(y), z: Float(z))
	}
}

struct DebugInfo {
	private(set) var touchPosition: TouchPosition
	private(set) var hivePosition: Position
	private(set) var scale: CGPoint
	private(set) var offset: CGPoint

	init(
		touchPosition: TouchPosition,
		hivePosition: Position = .origin,
		scale: CGPoint = .zero,
		offset: CGPoint = .zero
	) {
		self.touchPosition = touchPosition
		self.hivePosition = hivePosition
		self.scale = scale
		self.offset = offset
	}

	var touchPositionFormatted: String {
		String(format: "(%.2f, %.2f, %.2f)", touchPosition.x, touchPosition.y, touchPosition.z)
	}

	var hivePositionFormatted: String {
		hivePosition.description
	}

	mutating func update(touchPosition: TouchPosition, position: Position) {
		self.touchPosition = touchPosition
		self.hivePosition = position
	}

	mutating func update(scale: CGPoint, offset: CGPoint) {
		self.scale = scale
		self.offset = offset
	}
}

class DebugOverlay: UIView {
	var enabled: Bool {
		didSet {
			self.isHidden = !enabled
		}
	}

	var debugInfo: DebugInfo {
		didSet {
			touchPositionLabel.text = "Touch: \(debugInfo.touchPositionFormatted)"
			hivePositionLabel.text = "Hive: \(debugInfo.hivePositionFormatted)"
		}
	}

	private let touchPositionLabel = UILabel()
	private let hivePositionLabel = UILabel()

	init(enabled: Bool = false, debugInfo: DebugInfo = DebugInfo(touchPosition: .simd3(SIMD3<Float>()))) {
		self.enabled = enabled
		self.debugInfo = debugInfo
		super.init(frame: .zero)

		setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupView() {
		self.alpha = 0.5
		self.backgroundColor = UIColor(.backgroundRegular)

		touchPositionLabel.numberOfLines = 0
		hivePositionLabel.numberOfLines = 0

		let stackView = UIStackView(arrangedSubviews: [touchPositionLabel, hivePositionLabel])
		stackView.axis = .vertical
		stackView.alignment = .leading
		stackView.distribution = .fill
		addSubview(stackView)
		stackView.constrainToFillView(self)

		NSLayoutConstraint.activate([
			widthAnchor.constraint(equalToConstant: 200),
			heightAnchor.constraint(equalToConstant: 200),
		])
	}
}
