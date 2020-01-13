//
//  ARGameView.swift
//  Hive for iOS
//
//  Created by Joseph Roque on 2019-11-30.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import SwiftUI
import RealityKit

struct ARGameView: UIViewRepresentable {
	func makeUIView(context: Context) -> ARView {
		let arView = ARView(frame: .zero)

		let boxAnchor = try! Experience.loadBox()

		arView.scene.anchors.append(boxAnchor)

		return arView
	}

	func updateUIView(_ uiView: ARView, context: Context) {}
}
