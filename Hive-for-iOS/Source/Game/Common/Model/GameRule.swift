//
//  GameRule.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-03-27.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

enum GameRule: String, CaseIterable {
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

	var description: String {
		switch self {
		case .objective: return
			"The objective of the game is to surround your opponent's [queen](class:Queen) on all 6 sides, " +
				"before they are able to surround yours. The first player to do so, wins. " +
				"The pieces surrounding the [queen](class:Queen) can be either friendly or not."
		case .placement: return
			"On your turn you can either [move a piece](rule:movement) or place a piece. " +
				"Your first piece can be played anywhere, but each subsequent piece can only be placed " +
				"**adjacent** to at least one other friendly piece, and **apart** from all enemy pieces. " +
				"The [queen](class:Queen) must be placed within the player's **first four moves**."
		case .movement: return
			"On your turn you can either move a piece or [place a piece](rule:placement). " +
				"Each type of piece moves in a unique way, and can be learned by looking through the rules, " +
				"or by tapping on any piece on the board or in your hand. Moving a piece must always " +
				"respect the [freedom of movement](rule:freedomOfMovement) rule and the [one hive](rule:oneHive) " +
				"rule. A player cannot move their pieces until they have [placed](rule:placement) their " +
				"[queen](class:Queen). If a player is ever unable to move or place a piece, they must " +
				"[pass their turn](rule:passing). If they have any moves available, then they **must** move. " +
				"The [pill bug](class:Pill Bug) adds additional complexity to moving pieces and should be " +
				"explored separately."
		case .freedomOfMovement: return
			"When moving around the board, a piece cannot move between two pieces which do not have " +
				"a **full space** between them. This also applies to pieces moving onto or down from the hive."
		case .oneHive: return
			"The hive must remain connected at all times, which means every piece must always be touching " +
				"**at least one other piece**. If moving a piece would cause the hive to become split, then " +
				"**that piece cannot be moved**."
		case .stacks: return
			"[Beetles](class:Beetle) and [mosquitoes](class:Mosquito) can be moved on top of other pieces, " +
				"creating stacks. A stack's color is identical to the piece on top of it. Only the top piece " +
				"of a stack can be moved, and [mosquitoes](class:Mosquito) can only copy the top piece."
		case .passing: return
			"If a player is ever unale to [place a new piece](rule:placement) or " +
				"[move an existing piece](rule:movement) they must forfeit their turn. The opponent takes another " +
				"turn, and continues to do so until the other player can move or their [queen](class:Queen) " +
				"is surrounded. Please note, if a player is able to move, they they **must do so**."
		case .endingTheGame: return
			"The game is over when one player's [queen](class:Queen) becomes surrounded on all 6 sides. " +
				"The player whose [queen](class:Queen) is surrounded loses, and their opponent wins. In the case " +
				"that both [queens](class:Queen) become surrounded at the same time, the game **ends in a draw**."
		}
	}
}

extension Piece.Class {
	var rules: String {
		switch self {
		case .ant: return
			"Ants are the most mobile piece in the game. They can travel any number of spaces around the board, " +
				"respecting the [freedom of movement](rule:freedomOfMovement) rule."
		case .beetle: return
			"Beetles can only move one space at a time, similar to the [queen](class:Queen). However, they can " +
				"also move **on top of the hive**, immobilizing the piece beneath it and forming a " +
				"[stack](rule:stacks). A [stack](rule:stacks) becomes the color of whichever piece is on top. " +
				"Beetles must respect the [freedom of movement](rule:freedomOfMovement) rule while on top of the " +
				"hive, and beetles are capable of **stacking multiple pieces high**. They can return to " +
				"the ground at any time, so long as they are not blocked."
		case .hopper: return
			"Grasshoppers (or hoppers) do not move around the board, but rather jump in a straight line over " +
				"**at least one other piece**, to the next unoccupied space."
		case .ladyBug: return
			"Lady Bugs always move **exactly 3 spaces**, the first 2 of which must be on top of the hive, with " +
				"the final move returning the piece to the ground. The lady bug must " +
				"**always finish on the ground**. While moving onto or down from the hive, the lady bug must " +
				"respect the [freedom of movement](rule:freedomOfMovement) rule."
		case .mosquito: return
			"Mosquitoes do not have any movements of their own. Instead, they copy the movements or abilities " +
				"of any piece they are directly adjacent to. For example, a mosquito which is adjacent to an " +
				"opponent's [ant](class:Ant) and a friendly [queen](class:Queen) can move as either an " +
				"[ant](class:Ant) or a [queen](class:Queen) on that turn. Mosquitoes can copy a beetle and move " +
				"on top of the hive. If it does, it **remains a beetle until it returns to the ground**. A mosquito " +
				"which is adjacent only to another mosquito **has no moves to copy** and therefore cannot be moved. " +
				"When adjacent to a [stack](rule:stacks) a mosquito can only copy the moves of the piece on top."
		case .pillBug: return
			"Pill Bugs can only move one space at a time, similar to the [queen](class:Queen). However, they also " +
				"have a **special ability** which allows them to take any piece which is adjacent to it, friendly " +
				"or not, move it up on top of the pill bug's back, and then back down to an adjacent, free space. " +
				"The pill bug **cannot move pieces which are stacked**. The piece being moved must respect the " +
				"[freedom of movement](rule:freedomOfMovement) as it moves up and back down. Finally, a piece which " +
				"has just moved or been moved by the pill bug **cannot be moved on the next turn**, nor can a " +
				"pill bug move a piece which has just moved or been moved in the previous turn."
		case .queen: return
			"The queen can only move one space at a time. It must respect the " +
				"[freedom of movement](rule:freedomOfMovement) rule when it moves. The game is over when one " +
				"player is able to surround the opponent's queen on all 6 sides with pieces from **either player**. " +
				"A player cannot move any other piece until their queen has been [placed](rule:placement)."
		case .spider: return
			"Spiders always move **exactly 3 spaces** around the outside of the hive. It must respect the " +
				"[freedom of movement](rule:freedomOfMovement) rule when it moves."
		}
	}
}
