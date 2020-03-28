//
//  Markdown.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-27.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Regex

struct Markdown: UIViewRepresentable {
	private let text: String
	private let maxWidth: CGFloat

	private let label = UILabel()

	init(_ text: String, maxWidth: CGFloat) {
		self.text = text
		self.maxWidth = maxWidth
	}

	func makeUIView(context: Context) -> UILabel {
		label.lineBreakMode = .byWordWrapping
		label.numberOfLines = 0
		label.font = UIFont.systemFont(ofSize: Metrics.Text.body.rawValue)
		label.preferredMaxLayoutWidth = maxWidth
		label.attributedText = parse(markdown: text).attributedString
		label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
		label.setContentHuggingPriority(.required, for: .vertical)
		label.sizeToFit()
		return label
	}

	func updateUIView(_ uiView: UILabel, context: Context) {
		label.sizeToFit()
	}
}

// MARK: - Preview

#if DEBUG
struct MarkdownPreview: PreviewProvider {
	static var previews: some View {
		GeometryReader { geometry in
			return Markdown("This is a **test** with a red [link](class:Queen)", maxWidth: geometry.size.width)
				.frame(minWidth: 0, maxWidth: geometry.size.width, minHeight: 0, maxHeight: geometry.size.height)
				.background(Color(.background))
		}
	}
}
#endif

// MARK: - Markdown Parsing

enum MarkdownElement {
	case plain(String)
	case bold(String)
	case link(String, GameInformation)

	var string: String {
		switch self {
		case .plain(let string), .bold(let string), .link(let string, _): return string
		}
	}
}

private let boldRegex = Regex(#"\*\*(.*?)\*\*"#)
private let linkRegex = Regex(#"\[([^\]]*?)\]\(((rule|class):\w+)\)"#)

private func parse(markdown: String) -> [MarkdownElement] {
	var elements: [MarkdownElement] = []
	let allMatches = (boldRegex.allMatches(in: markdown) + linkRegex.allMatches(in: markdown)).sorted {
		$0.range.lowerBound < $1.range.lowerBound
	}

	var previousEnd = markdown.startIndex
	for match in allMatches {
		if previousEnd < match.range.lowerBound {
			elements.append(.plain(String(markdown[previousEnd..<match.range.lowerBound])))
		}

		if match.matchedString.starts(with: "**") {
			elements.append(.bold(String(markdown[match.range])))
		} else if match.matchedString.starts(with: "[") {
			guard let content = match.captures[0],
				let linkContent = match.captures[1],
				let link = GameInformation(fromLink: linkContent) else {
				fatalError("Unsupported Markdown link: \(match.matchedString)")
			}
			elements.append(.link(content, link))
		} else {
			fatalError("Unsupported Markdown element matched: \(match.matchedString)")
		}
		previousEnd = match.range.upperBound
	}

	if previousEnd < markdown.endIndex {
		elements.append(.plain(String(markdown[previousEnd...])))
	}

	return elements
}

extension Array where Element == MarkdownElement {
	var attributedString: NSAttributedString {
		let mutable = NSMutableAttributedString()
		self.forEach { formattedText in
			var attributes: [NSAttributedString.Key: Any] = [:]
			switch formattedText {
			case .plain:
				attributes[.foregroundColor] = UIColor(.text)
				attributes[.font] = UIFont.systemFont(ofSize: Metrics.Text.body.rawValue)
			case .bold:
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

//enum FormattedText {
//	case plain(String)
//	case highlight(String)
//	case link(String, GameInformation)
//
//	var string: String {
//		switch self {
//		case .plain(let string), .highlight(let string), .link(let string, _): return string
//		}
//	}
//}

//struct Markdown: UIViewRepresentable {
//	let text: [FormattedText]
//	let maxWidth: CGFloat
//
//	private let label = UILabel()
//
//	var height: CGFloat {
//		return label.frame.height
//	}
//
//	func makeUIView(context: Context) -> UILabel {
//		label.frame = CGRect(x: 0, y: 0, width: maxWidth, height: .greatestFiniteMagnitude)
//		label.lineBreakMode = .byWordWrapping
//		label.numberOfLines = 0
//		label.attributedText = formatText(text)
//		label.preferredMaxLayoutWidth = maxWidth
//		label.font = UIFont.systemFont(ofSize: Metrics.Text.body.rawValue)
//		label.sizeToFit()
//		return label
//	}
//
//	func updateUIView(_ uiView: UILabel, context: Context) {
//		label.sizeToFit()
//	}
//
//	private func formatText(_ text: [FormattedText]) -> NSAttributedString {
//		let mutable = NSMutableAttributedString()
//		text.forEach { formattedText in
//			var attributes: [NSAttributedString.Key: Any] = [:]
//			switch formattedText {
//			case .plain:
//				attributes[.foregroundColor] = UIColor(.text)
//				attributes[.font] = UIFont.systemFont(ofSize: Metrics.Text.body.rawValue)
//			case .highlight:
//				attributes[.foregroundColor] = UIColor(.text)
//				attributes[.font] = UIFont.boldSystemFont(ofSize: Metrics.Text.body.rawValue)
//			case .link:
//				attributes[.foregroundColor] = UIColor(.primary)
//				attributes[.font] = UIFont.boldSystemFont(ofSize: Metrics.Text.body.rawValue)
//			}
//
//			mutable.append(NSAttributedString(string: formattedText.string, attributes: attributes))
//		}
//
//		return mutable
//	}
//}
