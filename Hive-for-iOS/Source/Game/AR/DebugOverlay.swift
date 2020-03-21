//
//  DebugOverlay.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-18.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import UIKit
import HiveEngine

struct DebugInfo {
	let touchPosition: SIMD3<Float>
	let hivePosition: Position

	init(touchPosition: SIMD3<Float> = SIMD3<Float>(), hivePosition: Position = .origin) {
		self.touchPosition = touchPosition
		self.hivePosition = hivePosition
	}

	var touchPositionFormatted: String {
		String(format: "(%.2f, %.2f, %.2f)", touchPosition.x, touchPosition.y, touchPosition.z)
	}

	var hivePositionFormatted: String {
		hivePosition.description
	}
}

class DebugOverlay: UIView {
	override var canBecomeFirstResponder: Bool {
		get { true }
	}

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

	init(enabled: Bool = false, debugInfo: DebugInfo = DebugInfo()) {
		self.enabled = enabled
		self.debugInfo = debugInfo
		super.init(frame: .zero)

		setupView()
		becomeFirstResponder()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupView() {
		self.alpha = 0.5
		self.backgroundColor = UIColor(.background)

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

	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			self.enabled.toggle()
		}
	}
}
