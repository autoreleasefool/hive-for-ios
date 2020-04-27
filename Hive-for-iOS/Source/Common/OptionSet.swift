//
//  OptionSet.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-26.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

enum OptionSet {
	static func parse<T>(_ string: String) -> Set<T> where T: Hashable, T: RawRepresentable, T.RawValue == String {
		var options: Set<T> = []
		string.split(separator: ";").forEach {
			let optionAndValue = $0.split(separator: ":")
			guard optionAndValue.count == 2 else { return }
			if Bool(String(optionAndValue[1])) ?? false,
				let option = T(rawValue: String(optionAndValue[0])) {
				options.insert(option)
			}
		}
		return options
	}

	static func encode<T>(_ options: Set<T>) -> String
		where T: Hashable,
		T: RawRepresentable,
		T: CaseIterable,
		T.RawValue == String {
		T.allCases
			.map { "\($0.rawValue):\(options.contains($0))" }
			.joined(separator: ";")
	}
}
