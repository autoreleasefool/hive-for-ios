//
//  LoginField.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-31.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import UIKit
import SwiftUI

struct LoginField: UIViewRepresentable {
	let title: String
	var text: Binding<String>
	var isFirstResponder: Binding<Bool>
	let isSecure: Bool

	init(_ title: String, text: Binding<String>, isActive: Binding<Bool>, isSecure: Bool) {
		self.title = title
		self.text = text
		self.isFirstResponder = isActive
		self.isSecure = isSecure
	}

	func makeUIView(context: UIViewRepresentableContext<LoginField>) -> UITextField {
		let textField = UITextField(frame: .zero)
		textField.delegate = context.coordinator

		let leftView = UIView(frame: CGRect(x: 0, y: 0, width: Metrics.Spacing.m.rawValue, height: 1))
		let rightView = UIView(frame: CGRect(x: 0, y: 0, width: Metrics.Spacing.m.rawValue, height: 1))
		textField.leftView = leftView
		textField.leftViewMode = .always
		textField.rightView = rightView
		textField.rightViewMode = .always

		textField.layer.borderColor = UIColor(.background).cgColor
		textField.layer.borderWidth = 1.0
		textField.layer.cornerRadius = Metrics.Spacing.s.rawValue

		textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

		return textField
	}

	func makeCoordinator() -> LoginField.Coordinator {
		Coordinator(text: text)
	}

	func updateUIView(_ textField: UITextField, context: UIViewRepresentableContext<LoginField>) {
		let color = UIColor(isFirstResponder.wrappedValue ? .primary : .textSecondary)
		textField.isSecureTextEntry = isSecure
		let attributes = [NSAttributedString.Key.foregroundColor: color.withAlphaComponent(0.5)]
		textField.attributedPlaceholder = NSAttributedString(string: title, attributes: attributes)
		textField.textColor = color
		textField.layer.borderColor = color.cgColor
		textField.text = text.wrappedValue

		guard textField.window != nil else { return }
		if isFirstResponder.wrappedValue && !context.coordinator.didBecomeFirstResponder {
			textField.becomeFirstResponder()
			context.coordinator.didBecomeFirstResponder = true
		} else if !isFirstResponder.wrappedValue {
			context.coordinator.didBecomeFirstResponder = false
		}
	}

	class Coordinator: NSObject, UITextFieldDelegate {
		var text: Binding<String>
		var didBecomeFirstResponder = false

		init(text: Binding<String>) {
			self.text = text
		}

		func textFieldDidChangeSelection(_ textField: UITextField) {
			text.wrappedValue = textField.text ?? ""
		}
	}
}

#if DEBUG
struct LoginField_Previews: PreviewProvider {
	@State static var text: String = "Email"
	@State static var isActive: Bool = true

	static var previews: some View {
		LoginField("Email", text: $text, isActive: $isActive, isSecure: false)
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
			.padding(.all, length: .m)
			.background(Color(.background))
	}
}
#endif
