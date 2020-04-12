//
//  AppDelegate.swift
//  Hive for iOS
//
//  Created by Joseph Roque on 2019-11-30.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {

		Theme.applyPrimaryTheme()

		// Create Account container and attempt to load credentials
		let account = Account()
		HiveAPI.shared.setAccount(to: account)

		// Create settings and load preferences
		let settings = Settings()

		// Create the SwiftUI view that provides the window contents.
		let contentView = Home()
			.environmentObject(account)
			.environmentObject(settings)

		// Use a UIHostingController as window root view controller.
		let window = UIWindow(frame: UIScreen.main.bounds)
		window.rootViewController = HostingController(rootView: contentView)
		window.rootViewController?.overrideUserInterfaceStyle = .dark
		self.window = window
		window.makeKeyAndVisible()
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) { }

	func applicationDidEnterBackground(_ application: UIApplication) { }

	func applicationWillEnterForeground(_ application: UIApplication) { }

	func applicationDidBecomeActive(_ application: UIApplication) { }
}
