//
//  BetterTabBar.swift
//  Hive-for-iOS
//
//  Source: https://gist.github.com/Amzd/2eb5b941865e8c5cccf149e6e07c8810
//

import SwiftUI
import UIKit

struct BetterTabView: View {
	var viewControllers: [UIHostingController<AnyView>]
	@State var selectedIndex: Int = 0

	init(_ views: [Tab]) {
		self.viewControllers = views.map {
			let host = UIHostingController(rootView: $0.view)
			host.tabBarItem = $0.barItem
			return host
		}
	}

	var body: some View {
		TabBarController(controllers: viewControllers, selectedIndex: $selectedIndex)
			.edgesIgnoringSafeArea(.all)
	}

	struct Tab {
		var view: AnyView
		var barItem: UITabBarItem

		init<V: View>(view: V, barItem: UITabBarItem) {
			self.view = AnyView(view)
			self.barItem = barItem
		}

		init<V: View>(view: V, title: String?, image: String, selectedImage: String? = nil) {
			let selectedImage = selectedImage != nil ? UIImage(systemName: selectedImage!) : nil
			let barItem = UITabBarItem(title: title, image: UIImage(systemName: image), selectedImage: selectedImage)
			self.init(view: view, barItem: barItem)
		}
	}
}

struct TabBarController: UIViewControllerRepresentable {
	var controllers: [UIViewController]
	@Binding var selectedIndex: Int

	func makeUIViewController(context: Context) -> UITabBarController {
		let tabBarController = UITabBarController()
		tabBarController.viewControllers = controllers
		tabBarController.delegate = context.coordinator
		tabBarController.selectedIndex = 0
		return tabBarController
	}

	func updateUIViewController(_ tabBarController: UITabBarController, context: Context) {
		tabBarController.selectedIndex = selectedIndex
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: NSObject, UITabBarControllerDelegate {
		var parent: TabBarController

		init(_ tabBarController: TabBarController) {
			self.parent = tabBarController
		}

		func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
			parent.selectedIndex = tabBarController.selectedIndex
		}
	}
}

#if DEBUG
struct BetterTabBarPreview: PreviewProvider {
	static var previews: some View {
		EmptyView()
//		BetterTabView([
//			BetterTabView.Tab(view: Text("First"), title: "First", image: "clock"),
//			BetterTabView.Tab(view: Text("Second"), title: "Second", image: "hand.raised"),
//		])
	}
}
#endif
