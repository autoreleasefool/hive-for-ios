//
//  HiveRule.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-27.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation

enum HiveRule: CaseIterable {
	case objective
	case placement
	case movement
	case oneHive
	case freedomOfMovement
	case stacks
	case passing
	case endingTheGame

	var title: String {
		switch self {
		case .objective: return "Objective of the game"
		case .placement: return "Placing a piece"
		case .movement: return "Moving a piece"
		case .freedomOfMovement: return "Freedom of movement"
		case .oneHive: return "One hive"
		case .stacks: return "Stacks"
		case .passing: return "Passing"
		case .endingTheGame: return "Ending the game"
		}
	}

	var description: [FormattedText] {
		switch self {
		case .objective: return [
			.plain("The objective of the game is to surround your opponent's "),
			.link("queen", .pieceClass(.queen)),
			.plain(" on all 6 sides, before they are able to surround yours. The first player to do so, wins. "),
			.plain("The pieces surrounding the "),
			.link("queen", .pieceClass(.queen)),
			.plain(" can be either friendly or not."),
			]
		case .placement: return [
			.plain("On your turn you can either "),
			.link("move a piece", .rule(.movement)),
			.plain(" or place a piece. Your first piece can be played anywhere, "),
			.plain("but each subsequent piece must be placed"),
			.highlight("adjacent"),
			.plain(" to a friendly piece, and "),
			.highlight("apart"),
			.plain(" from all enemy pieces."),
			]
		case .movement: return [
			.plain("On your turn you can either move a piece or "),
			.link("place a piece", .rule(.placement)),
			.plain("Each type of piece moves in a unique way, and can be learned by looking through the rules, "),
			.plain("or by tapping on any piece on the board or in your hand. "),
			.plain("Moving a piece must always respect the "),
			.link("freedom of movement", .rule(.freedomOfMovement)),
			.plain(" rule and the "),
			.link("one hive", .rule(.oneHive)),
			.plain(" rule. If a player is ever unable to move or place a piece, they must "),
			.link("pass their turn", .rule(.passing)),
			.plain(". If they have any moves available, then they "),
			.highlight("must"),
			.plain(" move. The "),
			.link("pill bug", .pieceClass(.pillBug)),
			.plain(" adds additional complexity to moving pieces and should be learned. "),
			]
		case .freedomOfMovement: return [
			.plain("When moving around the board, a piece cannot move between two pieces which do not have a "),
			.highlight("full space"),
			.plain(" between them. This also applies to pieces moving onto or down from the hive."),
			]
		case .oneHive: return [
			.plain("The hive must remain connected at all times, which means every piece must always be touching "),
			.plain("at least one other piece."),
			.plain("If moving a piece would cause the hive to become split, then "),
			.highlight("that piece cannot be moved"),
			.plain("."),
			]
		case .stacks: return [
			.link("Beetles", .pieceClass(.beetle)),
			.plain(" and "),
			.link("mosquitoes", .pieceClass(.mosquito)),
			.plain(" can be moved on top of other pieces, creating stacks."),
			.plain("A stack's color is identical to the piece on top of it. "),
			.plain("Only the top piece can be moved, and "),
			.link("mosquitoes", .pieceClass(.mosquito)),
			.plain(" can only copy the top piece."),
			]
		case .passing: return [
			.plain("If a player is ever unable to "),
			.link("place a new piece", .rule(.placement)),
			.plain(" or "),
			.link("move an existing piece", .rule(.movement)),
			.plain(" they must "),
			.highlight("forfeit their turn"),
			.plain(". The opponent takes another turn, and continues until the player can move or their "),
			.link("queen", .pieceClass(.queen)),
			.plain(" is surrounded. Please note, if a player can move, then they "),
			.highlight("must"),
			.plain(".")
			]
		case .endingTheGame: return [
			.plain("The game is over when one player's "),
			.link("queen", .pieceClass(.queen)),
			.plain(" becomes surrounded on all 6 sides. The player whose "),
			.link("queen", .pieceClass(.queen)),
			.plain(" is surrounded loses, and their opponent wins. In the case that both "),
			.link("queens", .pieceClass(.queen)),
			.plain(" become surrounded at the same time, the game "),
			.highlight("ends in a draw"),
			.plain("."),
			]
		}
	}
}

extension Piece.Class {
	var rules: [FormattedText] {
		switch self {
		case .ant: return [
			.plain("Ants are the most mobile piece in the game. "),
			.plain("They can travel any number of spaces around the board, respecting the "),
			.link("freedom of movement", .rule(.freedomOfMovement)),
			.plain(" rule."),
			]
		case .beetle: return [
			.plain("Beetles can only move one space at a time, similar to "),
			.link("the queen", .pieceClass(.queen)),
			.plain(". However, they can also move "),
			.highlight("on top of the hive"),
			.plain(", immobilizing the piece beneath it. A "),
			.link("stack", .rule(.stacks)),
			.plain(" becomes the color of whichever piece is on top. "),
			.plain("Beetles must respect the "),
			.link("freedom of movement", .rule(.freedomOfMovement)),
			.plain(" rule while on top of the hive, and beetles are capable of "),
			.highlight("stacking multiple pieces high. "),
			.plain("They can return to the ground at any time, so long as they are not blocked."),
			]
		case .hopper: return [
			.plain("Grasshoppers (or hoppers) do not move around the board, but rather jump in a straight line over "),
			.highlight("at least 1 other piece"),
			.plain(", to the next unoccupied space."),
			]
		case .ladyBug: return [
			.plain("Lady Bugs always move "),
			.highlight("exactly 3 spaces"),
			.plain(", the first 2 of which must be on top of the hive, "),
			.plain("with the final move returning the piece to the ground. "),
			.plain("The lady bug must "),
			.highlight("always finish on the ground."),
			.plain("While moving up to or down from the hive, the lady bug must respect the "),
			.link("freedom of movement", .rule(.freedomOfMovement)),
			.plain(" rule.")
			]
		case .mosquito: return [
			.plain("Mosquitoes do not have any movements of their own. "),
			.plain("Instead, they copy the movements or abilities of any piece they are directly adjacent to. "),
			.plain("A mosquito which is adjacent to an opponent's "),
			.link("queen", .pieceClass(.queen)),
			.plain(" or a friendly "),
			.link("ant", .pieceClass(.ant)),
			.plain(" can move as either a "),
			.link("queen", .pieceClass(.queen)),
			.plain(" or an "),
			.link("ant", .pieceClass(.ant)),
			.plain(" on that turn. "),
			.plain("Mosquitos can copy a beetle and move on top of the hive. If it does, it "),
			.highlight("remains a beetle until it returns to the ground."),
			.plain("A mosquito which is only adjacent to another mosquito "),
			.highlight("has no moves to copy"),
			.plain(", and therefore cannot be moved. "),
			.plain("When adjacent to a"),
			.link("stack", .rule(.stacks)),
			.plain(" a mosquito can only copy the moves of the piece on top.")
			]
		case .pillBug: return [
			.plain("Pill Bugs can only move once space at a time, similar to "),
			.link("the queen", .pieceClass(.queen)),
			.plain(". However, they also have a "),
			.highlight("special ability"),
			.plain(" which allows them to move any piece which is adjacent to it,"),
			.highlight("friendly or not"),
			.plain(", and move it to an adjacent, free space. "),
			.plain("The pill bug "),
			.highlight("cannot move pieces which are stacked"),
			.plain(". Additionally, the piece being moved "),
			.plain("must respect the "),
			.link("freedom of movement", .rule(.freedomOfMovement)),
			.plain(" rule as it is moved to its new position. "),
			.plain("Finally, a piece which has just moved or been moved by the pill bug "),
			.highlight("cannot be moved on the next turn"),
			.plain(", nor can a pill bug move a piece which has just moved or been moved in the previous turn."),
			]
		case .queen: return [
			.plain("The queen can only move one space at a time. It must respect the "),
			.link("freedom of movement", .rule(.freedomOfMovement)),
			.plain(" rule when it moves. "),
			.highlight("The game is over"),
			.plain(" when one player is able to surround the opponent's queen on all 6 sides with pieces from "),
			.highlight("either player"),
			.plain(". A player "),
			.highlight("cannot move"),
			.plain(" any other piece until their queen has been played."),
			]
		case .spider: return [
			.plain("Spiders always move "),
			.highlight("exactly 3 spaces"),
			.plain(" around the outside of the hive. It must respect the"),
			.link("freedom of movement", .rule(.freedomOfMovement)),
			.plain(" rule when it moves."),
			]
		}
	}
}

