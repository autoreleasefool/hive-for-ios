//
//  ContentView.swift
//  Hive for iOS
//
//  Created by Joseph Roque on 2019-11-30.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import SwiftUI
import RealityKit

struct ContentView : View {
	var body: some View {
		return ARViewContainer().edgesIgnoringSafeArea(.all)
	}
}

struct ARViewContainer: UIViewRepresentable {
	func makeUIView(context: Context) -> ARView {
		let arView = ARView(frame: .zero)

		// Load the "Box" scene from the "Experience" Reality File
		let boxAnchor = try! Experience.loadBox()

		// Add the box anchor to the scene
		arView.scene.anchors.append(boxAnchor)

		return arView

	}

	func updateUIView(_ uiView: ARView, context: Context) {}
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
#endif
