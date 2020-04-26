//
//  Toaster.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-25.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine
import Loaf

struct Toaster: EnvironmentKey {
	let loaf: Store<LoafState?>

	static var defaultValue: Self { self.default }

	private static let `default` = Self(loaf: .init(nil))
}

extension EnvironmentValues {
	var toaster: Toaster {
		get { self[Toaster.self] }
		set { self[Toaster.self] = newValue }
	}
}

struct LoafModifier: ViewModifier {
	@Environment(\.toaster) private var toaster: Toaster
	@State private var loaf: Loaf?

	func body(content: Content) -> some View {
		content
			.loaf($loaf)
			.onReceive(loafUpdate) {
				self.loaf = $0
			}
	}

	private var loafUpdate: AnyPublisher<Loaf, Never> {
		toaster.loaf
			.filter { $0 != nil }
			.map { $0!.build() }
			.eraseToAnyPublisher()
	}
}

extension View {
	func plugInToaster() -> some View {
		self.modifier(LoafModifier())
	}
}
