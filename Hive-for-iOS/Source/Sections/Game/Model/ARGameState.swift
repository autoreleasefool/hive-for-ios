//
//  ARGameState.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine

class ARGameState: ObservableObject {
	@Published var previewedPieceName: String = ARGameState.pieceNames[0]
	@Published var previewedPieceDescription: String = ARGameState.pieceDescriptions[0]
	var index = 0

	init() {
		print("Creating new game state")
	}

	func updatePiece() {
		index += 1
		previewedPieceName = ARGameState.pieceNames[index]
		previewedPieceDescription = ARGameState.pieceDescriptions[index]
	}

	static let pieceNames: [String] = [
		"Ant",
		"Beetle",
		"Queen",
	]

	static let pieceDescriptions: [String] = [
		"Ants are friends",
		"Beetles are cool",
		"Queens are benevolent",
	]
}


