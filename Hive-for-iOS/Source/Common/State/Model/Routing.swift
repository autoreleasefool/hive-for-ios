//
//  Routing.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-13.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

struct Routing: Equatable {
	var mainRouting = ContentView.Routing()
	var lobbyRouting = Lobby.Routing()
	var gameContentRouting = GameContentCoordinator.Routing()
}
