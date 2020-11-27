import SwiftUI

struct ThemeNavigationLink<Content>: View where Content: View {
	private let title: String
	private let content: Content

	init(_ title: String, @ViewBuilder destination: () -> Content) {
		self.title = title
		self.content = destination()
	}

	var body: some View {
		ZStack {
			NavigationLink(destination: content) {
				EmptyView()
			}

			HStack {
				Text(title)
					.foregroundColor(Color(.textRegular))
					.font(.body)
				Spacer()
				Image(systemName: "chevron.right")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 7)
					.foregroundColor(Color(.dividerRegular))
			}
		}
	}
}
