//
//  LocalOpponent.swift
//  HiveFoundation
//
//  Created by Joseph Roque on 2020-12-05.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

public enum LocalOpponent: Identifiable {
	case human
	case agent(AgentConfiguration)

	public var name: String {
		switch self {
		case .human:
			return "Second player"
		case .agent(let agent):
			return agent.name
		}
	}

	public var id: UUID {
		switch self {
		case .human:
			return UUID(uuidString: "154b7a56-4520-405c-a44d-1257e20cae1a")!
		case .agent(let agent):
			return agent.id
		}
	}
}
