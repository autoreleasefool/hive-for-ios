//
//  BottomSheetView.swift
//
//  Created by Majid Jabrayilov
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//
// swiftlint:disable all

import SwiftUI

private enum Constants {
	static let radius: CGFloat = 16
	static let indicatorHeight: CGFloat = 6
	static let indicatorWidth: CGFloat = 60
	static let snapRatio: CGFloat = 0.25
}

struct BottomSheet<Content: View>: View {
	@Binding var isOpen: Bool

	let maxHeight: CGFloat
	let minHeight: CGFloat
	let backgroundColor: ColorAsset
	let showsDragIndicator: Bool
	let dragGestureEnabled: Bool
	let content: Content

	@GestureState private var translation: CGFloat = 0

	private var offset: CGFloat {
		isOpen ? 0 : maxHeight - minHeight
	}

	private var indicator: some View {
		RoundedRectangle(cornerRadius: Constants.radius)
			.fill(Color(.textRegular))
			.frame(
				width: Constants.indicatorWidth,
				height: Constants.indicatorHeight
		).onTapGesture {
			isOpen.toggle()
		}
	}

	init(isOpen: Binding<Bool>, minHeight: CGFloat, maxHeight: CGFloat, showsDragIndicator: Bool = true, dragGestureEnabled: Bool = true, backgroundColor: ColorAsset = .backgroundRegular, @ViewBuilder content: () -> Content) {
		self.minHeight = minHeight
		self.maxHeight = maxHeight
		self.showsDragIndicator = showsDragIndicator
		self.dragGestureEnabled = dragGestureEnabled
		self.backgroundColor = backgroundColor
		self.content = content()
		self._isOpen = isOpen
	}

	var body: some View {
		GeometryReader { geometry in
			VStack(spacing: 0) {
				if showsDragIndicator {
					indicator.padding()
				}
				content
			}
			.frame(width: geometry.size.width, height: maxHeight, alignment: .top)
			.background(Color(backgroundColor))
			.cornerRadius(Constants.radius)
			.frame(height: geometry.size.height, alignment: .bottom)
			.offset(y: max(offset + translation, 0))
			.animation(.interactiveSpring())
			.gesture(
				DragGesture().updating($translation) { value, state, _ in
					guard dragGestureEnabled else { return }
					state = value.translation.height
				}.onEnded { value in
					guard dragGestureEnabled else { return }
					let snapDistance = maxHeight * Constants.snapRatio
					guard abs(value.translation.height) > snapDistance else { return }
					isOpen = value.translation.height < 0
				}
			)
		}
	}
}

#if DEBUG
struct BottomSheetPreview: PreviewProvider {
	static var previews: some View {
		BottomSheet(isOpen: .constant(true), minHeight: 0, maxHeight: 300) {
			VStack {
				Text("First")
				Text("Second")
				Text("Third")
			}
		}
		.edgesIgnoringSafeArea(.all)
	}
}
#endif
