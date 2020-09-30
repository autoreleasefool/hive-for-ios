//
//  Markdown.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-27.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftyMarkdown
import SwiftUI

private struct MarkdownInternal: UIViewRepresentable {
	@Binding var height: CGFloat

	private let markdown: String
	private let didTapURL: ((URL) -> Void)?

	init(_ markdown: String, height: Binding<CGFloat>, didTapURL: ((URL) -> Void)? = nil) {
		self.markdown = markdown
		self._height = height
		self.didTapURL = didTapURL
	}

	func makeUIView(context: Context) -> UITextView {
		let label = UITextView()
		label.delegate = context.coordinator
		label.isEditable = false
		label.isScrollEnabled = false
		label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
		label.backgroundColor = nil
		label.delegate = context.coordinator
		return label
	}

	func updateUIView(_ label: UITextView, context: Context) {
		let md = SwiftyMarkdown(string: markdown)
		Theme.applyMarkdownTheme(to: md)

		label.delegate = context.coordinator
		label.attributedText = md.attributedString()
		MarkdownInternal.recalculateHeight(view: label, result: $height)
	}

	fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
		let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
		if result.wrappedValue != newSize.height {
			DispatchQueue.main.async {
				result.wrappedValue = newSize.height
			}
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(height: $height, didTapURL: didTapURL)
	}

	class Coordinator: NSObject, UITextViewDelegate {
		private var height: Binding<CGFloat>
		private let didTapURL: ((URL) -> Void)?

		init(height: Binding<CGFloat>, didTapURL: ((URL) -> Void)?) {
			self.height = height
			self.didTapURL = didTapURL
			super.init()
		}

		func textView(
			_ textView: UITextView,
			shouldInteractWith URL: URL,
			in characterRange: NSRange,
			interaction: UITextItemInteraction
		) -> Bool {
			self.didTapURL?(URL)
			return false
		}

		func textViewDidChange(_ textView: UITextView) {
			MarkdownInternal.recalculateHeight(view: textView, result: height)
		}
	}
}

struct MarkdownView: View {
	private let markdown: String
	private var dynamicHeight: Binding<CGFloat>
	let didTapURL: ((URL) -> Void)?

	init(_ markdown: String, height: Binding<CGFloat>, didTapURL: ((URL) -> Void)? = nil) {
		self.markdown = markdown
		self.dynamicHeight = height
		self.didTapURL = didTapURL
	}

	var body: some View {
		return MarkdownInternal(markdown, height: dynamicHeight, didTapURL: didTapURL)
			.frame(minHeight: dynamicHeight.wrappedValue, maxHeight: dynamicHeight.wrappedValue)
	}
}

// MARK: - Preview

#if DEBUG
struct MarkdownPreview: PreviewProvider {
	@State static var height: CGFloat = 90

	static var previews: some View {
		MarkdownView(
			"On 2 your turn you can either move a piece or [place a piece](rule:placement). " +
			"Each type of piece moves in a unique way, and can be learned by looking through the rules, " +
			"or by tapping on any piece on the board or in your hand. Moving a piece must always " +
			"respect the [freedom of movement](rule:freedomOfMovement) rule and the [one hive](rule:oneHive) " +
			"rule. A player cannot move their pieces until they have [placed](rule:placement) their " +
			"[queen](class:Queen). If a player is ever unable to move or place a piece, they must " +
			"[pass their turn](rule:passing). If they have any moves available, then they **must** move. " +
			"The [pill bug](class:Pill Bug) adds additional complexity to moving pieces and should be " +
			"explored separately.",
			height: $height
		)
		.frame(minHeight: height, maxHeight: height)
		.background(Color(.backgroundRegular))
		.background(Color(.highlightPrimary).edgesIgnoringSafeArea(.all))
	}
}
#endif
