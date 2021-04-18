//
//  AnyAccount.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2020-12-21.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

public struct AnyAccount: Account, Equatable {
	public let wrapped: Account

	public var id: UUID { return wrapped.id }
	public var token: String { return wrapped.token }
	public var isGuest: Bool { return wrapped.isGuest }
	public var isOffline: Bool { return wrapped.isOffline }
	public var headers: [String: String] { return wrapped.headers }

	public init(_ wrapped: Account) {
		self.wrapped = wrapped
	}

	public func applyAuth(to request: inout URLRequest) {
		wrapped.applyAuth(to: &request)
	}

	public static func == (lhs: AnyAccount, rhs: AnyAccount) -> Bool {
		if let hiveAccount = lhs.wrapped as? HiveAccount,
			let otherHiveAccount = rhs.wrapped as? HiveAccount {
			return hiveAccount == otherHiveAccount
		} else if let appleAccount = lhs.wrapped as? AppleAccount,
			let otherAppleAccount = rhs.wrapped as? AppleAccount {
			return appleAccount == otherAppleAccount
		}

		return false
	}
}

extension AnyAccount: Codable {
	enum Key: CodingKey {
		case type
		case wrappedValue
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Key.self)
		let type = try container.decode(String.self, forKey: .type)
		switch type {
		case "HiveAccount":
			self.wrapped = try container.decode(HiveAccount.self, forKey: .wrappedValue)
		case "AppleAccount":
			self.wrapped = try container.decode(AppleAccount.self, forKey: .wrappedValue)
		default:
			fatalError("Could not decode Account")
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: Key.self)
		if let hiveAccount = wrapped as? HiveAccount {
			try container.encode("HiveAccount", forKey: .type)
			try container.encode(hiveAccount, forKey: .wrappedValue)
		} else if let appleAccount = wrapped as? AppleAccount {
			try container.encode("AppleAccount", forKey: .type)
			try container.encode(appleAccount, forKey: .wrappedValue)
		}
	}
}

extension Loadable where T: Account {
	public func eraseToAnyAccount() -> Loadable<AnyAccount> {
		switch self {
		case .failed(let error):
			return .failed(error)
		case .notLoaded:
			return .notLoaded
		case .loading(let cached, let cancelBag):
			return .loading(cached: cached?.eraseToAnyAccount(), cancelBag: cancelBag)
		case .loaded(let account):
			return .loaded(account.eraseToAnyAccount())
		}
	}
}
