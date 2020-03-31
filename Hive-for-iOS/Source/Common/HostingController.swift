//
//  HostingViewController.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

class HostingController<Content>: UIHostingController<Content> where Content: View {
	@objc override var preferredStatusBarStyle: UIStatusBarStyle {
		.lightContent
	}
}
