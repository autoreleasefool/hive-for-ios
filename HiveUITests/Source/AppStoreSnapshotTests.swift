//
//  AppStoreSnapshotTests.swift
//  HiveUITests
//
//  Created by Joseph Roque on 2021-03-31.
//  Copyright © 2021 Joseph Roque. All rights reserved.
//

import XCTest
@testable import Hive_for_iOS

class AppStoreSnapshotTests: XCTestCase {

	override func setUp() {
		super.setUp()

		continueAfterFailure = false

		let app = XCUIApplication()
		app.launchEnvironment = [
			"disableAnimations": "1",
			"LocalGameString": #"Base+LMP;InProgress;Black[9];wA1;bS1 \wA1;wQ wA1-;bQ -bS1;wP wA1\;"# +
				#"bL \bS1;wA2 /wA1;bL \wQ;wA2 \bQ;bL wQ-;wB1 /wP;bM bS1/;wG1 /wA1;bA1 bM/;wG1 bM\;"# +
				#"bA1 wB1\;wG1 /wA2"#,
		]
		app.launchArguments += [
			"-gameMode",
			"2D",
		]
		app.launchArguments += [
			"-pieceColorScheme",
			"Filled",
		]
		app.launchArguments += [
			"-isMoveToCenterOnRotateEnabled",
			"true",
		]
		setupSnapshot(app)
		app.launch()
	}

	func testCaptureScreenshots() {
		captureWelcomeScreen()
		captureLocalMatch()
		capturePlayAgainstLocalPlayer()
		captureHiveGameInProgress()
	}

	func captureWelcomeScreen() {
		snapshotPortraitAndLandscape("01_Welcome")
	}

	func captureLocalMatch() {
		let app = XCUIApplication()

		app.buttons["playOffline"].firstMatch.tap()

		if isPhone {
			app.buttons["createMatch"].firstMatch.tap()
		} else {
			XCUIDevice.shared.orientation = .landscapeLeft
			sleep(2)
			app.buttons["createMatch"].firstMatch.tap()
			XCUIDevice.shared.orientation = .portrait
			sleep(2)
		}

		snapshotPortraitAndLandscape("02_LocalMatch")
	}

	func capturePlayAgainstLocalPlayer() {
		let app = XCUIApplication()

		app.buttons["playAgainstFriend"].firstMatch.tap()

		snapshotPortraitAndLandscape("03_PlayAgainstLocalPlayer")
	}

	func captureHiveGameInProgress() {
		let app = XCUIApplication()

		app.buttons["startMatch"].firstMatch.tap()
		snapshotPortraitAndLandscape("00_InGame")
	}

	private var isPhone: Bool {
		UIDevice.current.userInterfaceIdiom == .phone
	}

	private func snapshotPortraitAndLandscape(_ name: String) {
		snapshot(name)
		if !isPhone {
			XCUIDevice.shared.orientation = .landscapeLeft
			sleep(2)
			snapshot("\(name)Landscape")
			XCUIDevice.shared.orientation = .portrait
			sleep(2)
		}
	}
}
