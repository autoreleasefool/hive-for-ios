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
	let keyboardType: UIKeyboardType
	let returnKeyType: UIReturnKeyType
	var isFirstResponder: Bool
	let isSecure: Bool
	let onReturn: () -> Void

	init(
		_ title: String,
		text: Binding<String>,
		keyboardType: UIKeyboardType,
		returnKeyType: UIReturnKeyType,
		isActive: Bool,
		isSecure: Bool,
		onReturn: @escaping () -> Void
	) {
		self.title = title
		self.text = text
		self.keyboardType = keyboardType
		self.returnKeyType = returnKeyType
		self.isFirstResponder = isActive
		self.isSecure = isSecure
		self.onReturn = onReturn
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
		Coordinator(text: text, onReturn: onReturn)
	}

	func updateUIView(_ textField: UITextField, context: UIViewRepresentableContext<LoginField>) {
		let color = UIColor(isFirstResponder ? .primary : .textSecondary)
		textField.isSecureTextEntry = isSecure
		let attributes = [NSAttributedString.Key.foregroundColor: color.withAlphaComponent(0.5)]
		textField.attributedPlaceholder = NSAttributedString(string: title, attributes: attributes)
		textField.textColor = color
		textField.layer.borderColor = color.cgColor
		textField.text = text.wrappedValue
		textField.keyboardType = keyboardType
		textField.returnKeyType = returnKeyType

		guard textField.window != nil else { return }
		if isFirstResponder && !context.coordinator.didBecomeFirstResponder {
			textField.becomeFirstResponder()
			context.coordinator.didBecomeFirstResponder = true
		} else if !isFirstResponder {
			context.coordinator.didBecomeFirstResponder = false
		}
	}

	class Coordinator: NSObject, UITextFieldDelegate {
		var text: Binding<String>
		var onReturn: () -> Void
		var didBecomeFirstResponder = false

		init(text: Binding<String>, onReturn: @escaping () -> Void) {
			self.text = text
			self.onReturn = onReturn
		}

		func textFieldDidChangeSelection(_ textField: UITextField) {
			text.wrappedValue = textField.text ?? ""
		}

		func textFieldShouldReturn(_ textField: UITextField) -> Bool {
			if textField.returnKeyType == .done {
				textField.resignFirstResponder()
			}
			onReturn()
			return false
		}
	}
}

#if DEBUG
struct LoginField_Previews: PreviewProvider {
	@State static var text: String = "Email"
	@State static var isActive: Bool = true

	static var previews: some View {
		LoginField(
			"Email",
			text: $text,
			keyboardType: .default,
			returnKeyType: .default,
			isActive: isActive,
			isSecure: false,
			onReturn: { }
		)
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
			.padding(.all, length: .m)
			.background(Color(.background))
	}
}
#endif
