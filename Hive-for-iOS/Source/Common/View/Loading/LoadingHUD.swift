//
//  LoadingHUD.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-09.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import UIKit

class LoadingHUD {
	static let shared = LoadingHUD()

	private let window: UIWindow
	private let loadingView = UIActivityIndicatorView(style: .large)

	private init() {
		window = UIWindow(frame: UIScreen.main.bounds)

		let controller = UIViewController()
		controller.view.isUserInteractionEnabled = false

		window.rootViewController = controller
		window.windowLevel = .alert + 1
		window.accessibilityViewIsModal = true

		setupViews(in: controller)
	}

	private func setupViews(in controller: UIViewController) {
		let backgroundView = UIView()
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.backgroundColor = UIColor(.backgroundDark).withAlphaComponent(0.5)

		loadingView.translatesAutoresizingMaskIntoConstraints = false

		controller.view.addSubview(backgroundView)
		controller.view.addSubview(loadingView)

		NSLayoutConstraint.activate([
			backgroundView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
			backgroundView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
			backgroundView.topAnchor.constraint(equalTo: controller.view.topAnchor),
			backgroundView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor),

			loadingView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
			loadingView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
		])
	}

	func show() {
		DispatchQueue.main.async {
			self.loadingView.startAnimating()
			self.window.makeKeyAndVisible()
		}
	}

	func hide() {
		DispatchQueue.main.async {
			self.window.isHidden = true
			self.loadingView.stopAnimating()
		}
	}
}
