//
//  KeyboardAvoidance.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-31.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine

extension Publishers {
	static var keyboardHeight: AnyPublisher<CGFloat, Never> {
		let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
			.map { $0.keyboardHeight }

		let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
			.map { _ in CGFloat(0) }

		return MergeMany(willShow, willHide)
			.eraseToAnyPublisher()
	}
}

extension Notification {
	var keyboardHeight: CGFloat {
		(userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
	}
}

struct KeyboardAvoidance: ViewModifier {
	@State private var keyboardHeight: CGFloat = 0

	func body(content: Content) -> some View {
		content
			.padding(.bottom, keyboardHeight)
			.onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
	}
}

extension View {
	func avoidingKeyboard() -> some View {
		ModifiedContent(content: self, modifier: KeyboardAvoidance())
	}
}
