//
//  AttributionsList.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-07-07.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI

struct AttributionsList: View {
	var body: some View {
		List {
			ForEach(AttributionsList.attributions, id: \.name) { attribution in
				Section(header: self.sectionHeader(title: attribution.name)) {
					Text(attribution.license)
						.font(.body)
						.foregroundColor(Color(.textRegular))
						.multilineTextAlignment(.leading)
				}
			}
		}
		.navigationBarTitle("Attributions")
	}

	private func sectionHeader(title: String) -> some View {
		HStack {
			Text(title)
				.bold()
				.font(.body)
				.foregroundColor(Color(.textRegular))
				.padding(.horizontal, length: .m)
				.padding(.vertical, length: .s)
			Spacer()
		}
		.background(Color(.backgroundSectionHeader))
		.listRowInsets(.empty)
	}
}

// MARK: - Attributions

extension AttributionsList {
	struct Attribution {
		let name: String
		let license: String
	}

	private static var attributions: [Attribution] {
		[
			Attribution(
				name: "KeychainAccess",
				license:
				"""
				The MIT License (MIT)

				Copyright (c) 2014 kishikawa katsumi

				Permission is hereby granted, free of charge, to any person obtaining a copy
				of this software and associated documentation files (the "Software"), to deal
				in the Software without restriction, including without limitation the rights
				to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
				copies of the Software, and to permit persons to whom the Software is
				furnished to do so, subject to the following conditions:

				The above copyright notice and this permission notice shall be included in all
				copies or substantial portions of the Software.

				THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
				IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
				FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
				AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
				LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
				OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
				SOFTWARE.
				"""
			),
			Attribution(
				name: "Loaf",
				license:
				"""
				MIT License

				Copyright (c) 2019 Mat Schmid

				Permission is hereby granted, free of charge, to any person obtaining a copy
				of this software and associated documentation files (the "Software"), to deal
				in the Software without restriction, including without limitation the rights
				to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
				copies of the Software, and to permit persons to whom the Software is
				furnished to do so, subject to the following conditions:

				The above copyright notice and this permission notice shall be included in all
				copies or substantial portions of the Software.

				THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
				IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
				FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
				AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
				LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
				OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
				SOFTWARE.
				"""
			),
			Attribution(
				name: "SwiftyMarkdown",
				license:
				"""
				The MIT License (MIT)

				Copyright (c) 2016 Simon Fairbairn

				Permission is hereby granted, free of charge, to any person obtaining a copy
				of this software and associated documentation files (the "Software"), to deal
				in the Software without restriction, including without limitation the rights
				to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
				copies of the Software, and to permit persons to whom the Software is
				furnished to do so, subject to the following conditions:

				The above copyright notice and this permission notice shall be included in all
				copies or substantial portions of the Software.

				THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
				IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
				FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
				AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
				LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
				OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
				SOFTWARE.
				"""
			),
		].sorted { $0.name < $1.name }
	}
}

// MARK: - Preview

#if DEBUG
struct AttributionsListPreview: PreviewProvider {
	static var previews: some View {
		AttributionsList()
	}
}
#endif
