//
//  FormattedText.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-27.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

enum FormattedText {
	case plain(String)
	case highlight(String)
	case link(String, GameInformation)

	var string: String {
		switch self {
		case .plain(let string), .highlight(let string), .link(let string, _): return string
		}
	}
}

struct FormattedLabel: UIViewRepresentable {
	let text: [FormattedText]
	let maxWidth: CGFloat

	private let label = UILabel()

	var height: CGFloat {
		return label.frame.height
	}

	func makeUIView(context: Context) -> UILabel {
		label.frame = CGRect(x: 0, y: 0, width: maxWidth, height: .greatestFiniteMagnitude)
		label.lineBreakMode = .byWordWrapping
		label.numberOfLines = 0
		label.attributedText = formatText(text)
		label.preferredMaxLayoutWidth = maxWidth
		label.font = UIFont.systemFont(ofSize: Metrics.Text.body.rawValue)
		label.sizeToFit()
		return label
	}

	func updateUIView(_ uiView: UILabel, context: Context) {
		label.sizeToFit()
	}

	private func formatText(_ text: [FormattedText]) -> NSAttributedString {
		let mutable = NSMutableAttributedString()
		text.forEach { formattedText in
			var attributes: [NSAttributedString.Key: Any] = [:]
			switch formattedText {
			case .plain:
				attributes[.foregroundColor] = UIColor(.text)
				attributes[.font] = UIFont.systemFont(ofSize: Metrics.Text.body.rawValue)
			case .highlight:
				attributes[.foregroundColor] = UIColor(.text)
				attributes[.font] = UIFont.boldSystemFont(ofSize: Metrics.Text.body.rawValue)
			case .link:
				attributes[.foregroundColor] = UIColor(.primary)
				attributes[.font] = UIFont.boldSystemFont(ofSize: Metrics.Text.body.rawValue)
			}

			mutable.append(NSAttributedString(string: formattedText.string, attributes: attributes))
		}

		return mutable
	}
}
