//
//  HostingViewController.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-14.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

class HostingController: UIHostingController<AnyView> {
	@objc override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}
